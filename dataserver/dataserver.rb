#!/usr/bin/env ruby
#
# mathflash - sinatra dataserver module
# Copyright (C) 2016, One Guy Coding
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

require 'fileutils'
require 'json'
require 'thread'
require 'sinatra/base'
require 'puma'
require 'daybreak'
require 'sqlite3'

ME = File.basename($PROGRAM_NAME, '.rb')
MD = File.expand_path(File.dirname(__FILE__))
MFSD = ENV['MFSD'] || File.join(MD, 'db')
PWDF = ENV['PWDF'] || File.join(MFSD, 'passwd.json')
MATHFLASH_DATA = File.join(MFSD, "mathflash_data.sqlite3")
MATHFLASH_INIT = File.join(MFSD, "mathflash_init.sql")
TS = Time.new.strftime('%Y%m%d_%H%M')
TMP = ENV['TMP'] || '/var/tmp'
LOG_DIR = File.join(TMP, ME)
NOW = Time.new.strftime('%Y%m')
LOG_FILE = "#{LOG_DIR}/#{ME}_#{NOW}.log".freeze

LIB=File.join(MD,"lib")

require File.join(LIB, "auth")
require File.join(LIB, "logger")
require File.join(LIB, "o_parser")

DOC_ROOT = File.expand_path(File.join(MD, '..'))
puts "root=#{DOC_ROOT}"

class String
	def to_boolean
		casecmp('true').zero? ? true : false
	end
end

$log = Logger::set_logger(STDOUT, Logger::DEBUG)
Auth::set_logger($log)

$log.info "Environment variable MFSD=#{MFSD}"
$log.die "Mathflash server data directory not found: #{MFSD}" unless File.directory?(MFSD)

$opts = {
	dir: File.dirname(__FILE__),
	port: 1963,
	addr: '0.0.0.0',
	ssl: false,
	pass: File.join(MFSD, 'passwd.json'),
	dbfile: MATHFLASH_DATA,
	log_file: nil,
	logger: $log,
	level: $log.level # Logger::DEBUG #INFO,
}

$opts = OParser.parse($opts, "#{MD}/data/help.txt") { |opts|
	opts.on('-p', '--port PORT', Integer, "Server port, default=#{$opts[:port]}") do |port|
		$opts[:port] = port
	end

	opts.on('-D', '--[no-]debug', 'Control debug logging') do |debug|
		$opts[:level] = debug ? Logger::DEBUG : Logger::INFO
	end

	opts.on('-l', '--logfile [FILE]', String, "Log file path, default=#{LOG_FILE}") do |log_file|
		$opts[:log_file] = log_file || LOG_FILE
	end

	opts.on('-h', '--help', 'Help') do
		puts opts

		puts "\npasswd data=" + $opts[:pass]
		puts

		exit 0
	end
}

class MathFlashDataServer < Sinatra::Base
	OPTION_DEFS={
		"left_max"=>10,
		"right_max"=>10,
		"count"=>25,
		"timeout"=>0
	}
	OPTION_KEYS=OPTION_DEFS.keys

	STATS_KEYS=%w/uid, operation, stimestamp, etimestamp, correct, count, percent/

	SQL_SELECT_NAME_GLOBAL='select name from global where uid == :uid'
	SQL_UPDATE_NAME_GLOBAL='UPDATE global SET name=:name WHERE uid == :uid'

	SQL_SELECT_NAME_NAMES='select name from names where uid == :uid'
	SQL_SELECT_ALL_NAMES='select * from names where uid == :uid AND name == :name LIMIT 1'

	SQL_INSERT_REPLACE_OPTIONS='INSERT OR REPLACE INTO names (uid, name, left_max, right_max, count, timeout) VALUES (:uid,:name,:left_max,:right_max,:count,:timeout)'

	SQL_SELECT_STATS='SELECT * FROM stats WHERE uid==:uid AND stimestamp >= :oldest AND stimestamp <= :newest ORDER BY stimestamp'
	SQL_INSERT_STATS='INSERT INTO stats (uid, operation, stimestamp, etimestamp, correct, count, percent) VALUES(:uid, :operation, :stimestamp, :etimestamp, :correct, :count, :percent)'

	def initialize
		Dir.chdir(DOC_ROOT)
		$log.info 'Working in ' + Dir.pwd

	$db = SQLite3::Database.new( $opts[:dbfile], :results_as_hash=>true )
	$db.execute(File.read(MATHFLASH_INIT)) { |row|
		row.each { |rs|
			puts rs.inspect
		}
	}

		#Auth.load_users(PWDF)
	end

	configure do
		# set :root, ME
		set :environment, :production
		set :bind, $opts[:addr]
		set :port, $opts[:port]
		set :sessions, true
		set :root, DOC_ROOT
		set :public_folder, DOC_ROOT
		set :show_exceptions, false
		set :dump_errors, true
		set :server, :puma
	end

	before do
		pi = request.path_info

		params[:db]=$db

		$log.debug "path_info="+request.path_info
		$log.debug "token="+(params.key?("token") ? params["token"] : "no token")
		$log.debug "params="+params.inspect
		$log.debug "client ip="+request.ip

		$log.debug "session="+session.inspect

		# on dataserver restart session tokens are lost, reload the token in the session
		if (!session.key?(:token) || !session.key?(:uid)) && params.key?("email")
			begin
				res = Auth.token_from_email(params)
			rescue => e
				$log.debug "No user: "+e.message
				halt 403, "User unknown"
			end

			$log.debug "res="+res.inspect
			if res.key?(:token) && res[:status]
				$log.debug "Found token for email="+params["email"]
				session[:token] = res[:token]
				session[:uid] = res[:uid]
			end
		end

		#$log.debug "session token="+session[:token] if session.key?(:token)

		#unless ['/', '/login'].include?(pi)
		#  halt 403, "Not authenticated" unless session.key?(:token)
		#  halt 403, "Token mismatch" unless session[:token].eql?(params[:token])
		#  break
		#end

		Dir.chdir(DOC_ROOT)
		# if request.request_method == 'GET' || request.request_method == 'POST'
		#    response.headers["Access-Control-Allow-Origin"] = "*"
		#    response.headers["Access-Control-Allow-Methods"] = "POST, GET"
		# end
		end

	helpers do
		$mathflash_data = File.join(MFSD, 'mathflash_data.json')
		$mutex = Mutex.new

		def read_save_sync(file, opts = { save: false })
			$mutex.synchronize do
				if opts[:save]
					puts "Saving file #{file}"
				else
					File.read(file)
				end
			end
		end

		def read_save_db(key, value, opts = { save: false })
			$mutex.synchronize do
				if opts[:save]
					$mathflash_db[key] = value
					$mathflash_db.flush
				else
					return $mathflash_db[key]
				end
			end
		end

		def read_db(uid)


		rescue => e
			halt 500, "Failed to read mathflash key=#{key}: " + e.to_s
		end

		def save_db(key, value)
			read_save_db(key, value, :save=>true)
		rescue => e
			halt 500, "Failed to save mathflash key=#{key} value=#{value.inspect}: " + e.to_s
		end

		def read_sync
			read_save_sync($mathflash_data)
		rescue => e
			halt 500, "Failed to read mathflash data: #{$mathflash_data}" + e.to_s
		end

		def write_sync
			read_save_sync($mathflash_data, save: true)
		rescue => e
			halt 500, "Failed to write mathflash data: #{$mathflash_data}" + e.to_s
		end

		def pre(data, fmt = 'json')
			data = JSON.pretty_generate(data) unless data.class == String
			return data unless fmt.eql?('pre')
			'<pre>' + data + '</pre>'
		end

	def data_section(json, keys = nil)
		data = JSON.parse(json, symbolize_names: true)
		return data if keys.nil?
		halt 500 unless keys.class == Array
		puts keys.to_json
		sections = {}
		keys.each do |key|
			break unless data.class == Hash
			halt 500, "Unknown key #{key}: #{json}" unless data.key?(key)
			sections[key] = data[key]
		end
		sections
	end

		def splat_keys(splat, keys = [])
			splat.each do |key|
				key.split('/').each do |k|
					keys << k.to_sym
				end
			end
			keys
		end
	end

	get '/' do
		File.read('index.html')
	end

	post '/login' do
		puts "/login params="+params.inspect
		res = Auth.login(params)
		puts "res="+res.inspect
		halt 403, res[:msg] if !res[:status]
		session[:token] = res[:token]
		session[:uid] = res[:uid]
		json = res.to_json
		puts "json="+json
		json
	end

	post '/logout' do
		puts "/logout params="+params.inspect
		res = Auth.logout(params)
		session[:token] = nil
		session[:uid] = nil
		json = res.to_json
		puts "json="+json
		json
	end

	# data format
	# global
	# 	options
	# names
	# 	default
	# 		options
	# 		stats
	# 	steeve
	# 		options: {
	# 		},
	# 		stats: {
	# 			"+"
	# 				"x" : []
	# 				"y0": []
	# 				"y1": []
	# 			"-"
	# 			"x"
	# 			"/"
	# 			}
	# 	etienne
	# 		options
	# 		stats
	#
	get '/mathflash.?:format?' do
		format = params[:format]
		json = read_sync
		pre data_section(json), format
	end

	get '/mathflash/global/name.?:format?' do
		format = params[:format] || 'json'
		name="default"
		$db.execute(SQL_SELECT_NAME_GLOBAL, "uid"=>session["uid"]) { |row|
			name=row['name']
			$log.debug "name=#{name}"
		}
		data={
			"name"=>name
		}
		pre data, format
	end

	post '/mathflash/global/name.?:format?' do
		format = params[:format] || 'json'
		name=params["name"]
		uid=session["uid"]
		data={
			:status => true,
			:msg => ""
		}
		begin
			$db.execute(SQL_UPDATE_NAME_GLOBAL, "name"=>name, "uid"=>uid) { |row|
				$log.debug "row=#{row.inspect}"
			}
		rescue => e
			halt 404, e.message
		end
		pre data, format
	end

	get '/mathflash/names.?:format?' do
		format = params[:format] || 'json'
		names=["default"]
		$db.execute(SQL_SELECT_NAME_NAMES, "uid"=>session["uid"]) { |row|
			name=row['name']
			$log.debug "name=#{name}"
			names << name
		}
		pre names, format
	end

	post '/mathflash/names' do
		puts "/login params="+params.inspect
		request.body.rewind  # in case someone already read it
		data = JSON.parse request.body.read
		$log.debug "data=#{data.inspect}"
		"Ok"
	end

	get '/mathflash/options.?:format?' do
		format = params[:format] || 'json'
		name = params["name"]
		uid = session["uid"]
		data = {
			:options => {}
		}

		if "default".eql?(name)
			data[:options]=OPTION_DEFS
		else
			$db.execute(SQL_SELECT_ALL_NAMES, "uid"=>uid, "name"=>name) { |row|
				OPTION_KEYS.each { |key|
					data[:options][key]=row[key]
				}
			}
			if data[:options].empty?
				data[:msg]="Options not found for uid %s and name %s, using defaults" % [ uid, name ]
				data[:options]=OPTION_DEFS
			end
		end
		pre data, format
	end

	post '/mathflash/options.?:format?' do
		format = params[:format] || 'json'
		name = params["name"]
		uid = session["uid"]
		options = JSON.parse(params["options"])
		options["uid"]=uid
		options["name"]=name

		data = {
			:status => true,
			:msg => ""
		}

		unless "default".eql?(name)
			begin
				$log.debug "uid=#{uid} name=#{name} options=#{options.to_json}"
				$db.execute(SQL_INSERT_REPLACE_OPTIONS, options) { |row|
						$log.debug "row=#{row.inspect}"
					}
				data[:status]=true
				data[:msg]=""
			rescue => e
				$log.error e.class+": "+e.message
				halt 404, "failed to update record for uid=#{uid} and name=#{name} with options=#{options.to_json}: #{e.message}"
			end
		end
		pre data, format
	end

	get '/mathflash/stats.?:format?' do
		format = params[:format] || 'json'
		name = params["name"]

		uid = session["uid"]
		oldest=params["oldest"]||0
		newest=params["newest"]||Time.now.to_i
		
		data={
			"uid"=>uid,
			"oldest"=>oldest,
			"newest"=>newest
		}
		stats = []
		$log.debug "sql=#{SQL_SELECT_STATS} data=#{data.inspect}"
		$db.execute(SQL_SELECT_STATS, data) { |row|
			$log.debug "row=#{row.inspect}"
			stat={}
			STATS_KEYS.each { |key|
				stat[key]=row[key]
			}
			stats << stat
		}
		stats
	end

	post '/mathflash/stats.?:format?' do
		format = params[:format] || 'json'
		name = params["name"]
		uid = session["uid"]
		stats = {}
		data = {
			:status => true,
			:msg => ""
		}
		begin
			stats = JSON.parse(params["stats"])
			stats["uid"]=uid
			$log.debug "stats=#{stats.inspect}"
			$log.debug "sql=#{SQL_INSERT_STATS}"
			$db.execute(SQL_INSERT_STATS, stats) { |row|
				$log.debug "row=#{row.inspect}"
			}
		rescue => e
			$log.error e.class+": "+e.message
			halt 404, "failed to update stats for uid=#{uid} and name=#{name} with stats=#{stats.to_json}"
		end
		pre data, format
	end

	run!
end

