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
require 'optparse'
require 'logger'
require 'json'
require 'thread'
require 'sinatra/base'
require 'puma'
require 'daybreak'

ME = File.basename($PROGRAM_NAME, '.rb')
MD = File.expand_path(File.dirname(__FILE__))
MFSD = ENV['MFSD'] || File.join(MD, 'db')
PWDF = ENV['PWDF'] || File.join(MFSD, 'passwd.json')
TS = Time.new.strftime('%Y%m%d_%H%M')
TMP = ENV['TMP'] || '/var/tmp'
LOG_DIR = File.join(TMP, ME)
NOW = Time.new.strftime('%Y%m')
LOG_FILE = "#{LOG_DIR}/#{ME}_#{NOW}.log".freeze

require File.join(MD, "lib", "auth")

DOC_ROOT = File.expand_path(File.join(MD, '..'))
puts "root=#{DOC_ROOT}"

class Logger
  def die(msg)
    error(msg)
    exit 1
  end
end

class String
  def to_boolean
    casecmp('true').zero? ? true : false
  end
end

def set_logger(stream, level)
  log = Logger.new(stream)
  log.level = level
  log.datetime_format = '%Y-%m-%d %H:%M:%S'
  log.formatter = proc do |severity, datetime, _progname, msg|
    "#{severity} #{datetime}: #{msg}\n"
  end
  log
end

$log = set_logger(STDOUT, Logger::DEBUG)

$log.info "Environment variable MFSD=#{MFSD}"
$log.die "Mathflash server data directory not found: #{MFSD}" unless File.directory?(MFSD)

$opts = {
  dir: File.dirname(__FILE__),
  port: 1963,
  addr: '0.0.0.0',
  ssl: false,
  pass: File.join(MFSD, 'passwd.json'),
  log_file: nil,
  level: $log.level # Logger::DEBUG #INFO
}

optparser = OptionParser.new do |opts|
  opts.banner = "#{ME}.rb [options]"

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
end
optparser.parse!

class MathFlashDataServer < Sinatra::Base
  def initialize
    Dir.chdir(DOC_ROOT)
    $log.info 'Working in ' + Dir.pwd
    Auth.load_users(PWDF)
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
    set :dump_errors, false
    set :server, :puma
  end

  before do
    Dir.chdir(DOC_ROOT)
    puts "before\n"+request.path_info
    # if request.request_method == 'GET' || request.request_method == 'POST'
    #    response.headers["Access-Control-Allow-Origin"] = "*"
    #    response.headers["Access-Control-Allow-Methods"] = "POST, GET"
    # end
  end

  helpers do
    $mathflash_db = Daybreak::DB.new File.join(MFSD,"mathflash_data.db")
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

    def read_db(key, value)
      read_save_db(key, value, :save=>false)
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
      unless keys.nil?
        puts keys.to_json
        keys.each do |key|
          break unless data.class == Hash
          halt 500, "Unknown key #{key}: #{json}" unless data.key?(key)
          data = data[key]
        end
      end
      data
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
	  puts params.inspect
    res = Auth.login(params)
    puts "res="+res.inspect
    halt 403, res[:msg] if !res[:status]
    session[:token] = res[:token]
    json = res.to_json
    puts "json="+json
    json
  end

  post '/logout' do
    puts "params="+params.inspect
    halt 403, "Not authenticated" unless session.key?(:token)
    halt 403, "Token mismatch" unless session[:token].eql?(params[:token])
    session[:token] = nil
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

  get '/mathflash/global.?:format?' do
    format = params[:format] || 'json'
    json = read_sync
    pre data_section(json, [:global]), format
  end

  get '/mathflash/global/*.?:format?' do
    format = params[:format] || 'json'
    puts 'splat=' + params['splat'].inspect
    json = read_sync
    keys = splat_keys(params['splat'], [:global])
    pre data_section(json, keys), format
  end

  get '/mathflash/names.?:format?' do
    format = params[:format] || 'json'
    json = read_sync
    pre data_section(json, [:names]).keys, format
  end

  get '/mathflash/names/*.?:format?' do
    format = params[:format] || 'json'
    puts "format=#{format} splat=" + params['splat'].inspect
    json = read_sync
    keys = splat_keys(params['splat'], [:names])
    pre data_section(json, keys), format
  end

  run!
end
