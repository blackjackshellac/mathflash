#!/usr/bin/env ruby
#

require 'fileutils'
require 'optparse'
require 'logger'
require 'json'
require 'thread'
require 'sinatra/base'
require 'puma'

ME=File.basename($0, ".rb")
MD=File.expand_path(File.dirname(__FILE__))
MFSD=ENV['MFSD']||File.join(MD,"data")
TS=Time.new.strftime("%Y%m%d_%H%M")
TMP=ENV['TMP'] || "/var/tmp"
LOG_DIR=File.join(TMP, ME)
NOW=Time.new.strftime("%Y%m")
LOG_FILE="#{LOG_DIR}/#{ME}_#{NOW}.log"

DOC_ROOT=File.expand_path(File.join(MD, ".."))
puts "root=#{DOC_ROOT}"

class Logger
    def die(msg)
        self.error(msg)
        exit 1
    end
end

class String
    def to_boolean
        return self.downcase.eql?("true") ? true : false;
    end
end

def set_logger(stream, level)
    log = Logger.new(stream)
    log.level = level
    log.datetime_format = "%Y-%m-%d %H:%M:%S"
    log.formatter = proc do |severity, datetime, progname, msg|
        "#{severity} #{datetime}: #{msg}\n"
    end
    log
end

$log=set_logger(STDOUT, Logger::DEBUG)

$log.info "Environment variable MFSD=#{MFSD}"
$log.die "Mathflash server data directory not found: #{MFSD}" unless File.directory?(MFSD)

$opts = {
    :dir  => File.dirname(__FILE__),
    :port => 1963,
    :addr => '0.0.0.0',
    :ssl  => false,
    :pass => File.join(MFSD, "passwd.json"),
    :log_file => nil,
    :level => $log.level # Logger::DEBUG #INFO
}

optparser = OptionParser.new { |opts|
    opts.banner = "#{ME}.rb [options]"

    opts.on('-p', '--port PORT', Integer, "Server port, default=#{$opts[:port]}") { |port|
        $opts[:port]=port
    }

    opts.on('-D', '--[no-]debug', "Control debug logging") { |debug|
        $opts[:level] = debug ? Logger::DEBUG : Logger::INFO
    }

    opts.on('-l', '--logfile [FILE]', String, "Log file path, default=#{LOG_FILE}") { |log_file|
        $opts[:log_file]=log_file||LOG_FILE
    }

    opts.on('-h', '--help', "Help") {
        puts opts

        puts "\npasswd data="+$opts[:pass]
        puts

        exit 0
    }
}
optparser.parse!

class MathFlashDataServer < Sinatra::Base

    configure {
        #set :root, ME
        set :environment, :production
        set :bind, $opts[:addr]
        set :port, $opts[:port]
        set :sessions, true
		set :root, DOC_ROOT
		set :public_folder, DOC_ROOT
        set :show_exceptions, false
        set :dump_errors, false
        set :server, :puma
    }

    before do
		Dir.chdir(DOC_ROOT)
        #if request.request_method == 'GET' || request.request_method == 'POST'
        #    response.headers["Access-Control-Allow-Origin"] = "*"
        #    response.headers["Access-Control-Allow-Methods"] = "POST, GET"
        #end
    end

helpers do
	$mathflash_data = File.join(MFSD, "mathflash_data.json")
	$mutex=Mutex.new

	def read_save_sync(file, opts={:save=>false})
		$mutex.synchronize {
			if opts[:save]
				puts "Saving file #{file}"
			else
				File.read(file)
			end
		}
	end

	def read_sync
		begin
			read_save_sync($mathflash_data)
		rescue => e
			halt 500, "Failed to read mathflash data: #{$mathflash_data}"+e.to_s
		end
	end

	def write_sync
		begin
			read_save_sync($mathflash_data, { :save=> true } )
		rescue => e
			halt 500, "Failed to write mathflash data: #{$mathflash_data}"+e.to_s
		end
	end

	def pre(data, fmt="json")
		data=JSON.pretty_generate(data) unless data.class == String
		return data unless fmt.eql?("pre")
		"<pre>"+data+"</pre>"
	end

	def data_section(json, keys=nil)
		data=JSON.parse(json, :symbolize_names=>true)
		return data if keys.nil?
		unless keys.nil?
			puts keys.to_json
			keys.each { |key|
				break unless data.class == Hash
				halt 500, "Unknown key #{key}: #{json}" unless data.key?(key)
				data=data[key]
			}
		end
		data
	end

	def splat_keys(splat, keys=[])
		splat.each { |key|
			key.split('/').each { |k|
				keys << k.to_sym
			}
		}
		keys
	end
end

get '/' do
	File.read("index.html")
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
	format=params[:format]
	json=read_sync
	pre data_section(json), format
end

get '/mathflash/global.?:format?' do
	format=params[:format]||"json"
	json=read_sync
	pre data_section(json, [:global]), format
end

get '/mathflash/global/*.?:format?' do
	format=params[:format]||"json"
	puts "splat="+params['splat'].inspect
	json=read_sync
	keys = splat_keys(params['splat'], [:global])
	pre data_section(json, keys), format
end

get '/mathflash/names.?:format?' do
	format=params[:format]||"json"
	json = read_sync
	pre data_section(json, [:names]).keys, format
end

get '/mathflash/names/*.?:format?' do
	format=params[:format]||"json"
	puts "format=#{format} splat="+params['splat'].inspect
	json = read_sync
	keys=splat_keys(params['splat'], [:names])
	pre data_section(json, keys), format
end

#get '/mathflash/names/:name/options' do
#	json = read_sync
#	name = params['name']
#	pre data_section(json, [:names, name.to_sym, :options])
#end

#get '/mathflash/names/:name/stats' do
#	json = read_sync
#	name = params['name']
#	pre data_section(json, [:names, name.to_sym, :stats])
#end


#get '/mathflash/stats/:name' do
#	name=params['name']
#	halt 404, "name parameter not found!" if name.nil?
#	json=nil
#	begin
#		json=read_save_sync($mathflash_data)
#	rescue => e
#		halt 404, "Failed to read mathflash data: #{$mathflash_data}"+e.to_s
#	end
#	puts "name=#{name}"
#	begin
#		data=JSON.parse(json, :symbolize_names => true)
#		stats=data[:stats]
#		halt 500, "No stats in #{$mathflash_data}: #{json}" if stats.nil?
#		halt 500, "No stats for name=#{name}: #{data.to_json}" unless stats.key?(name.to_sym)
#		stats = stats[name.to_sym]
#		puts stats
#		stats
#	rescue => e
#		"Failed to parse mathflash data: #{$mathflash_data}"+e.to_s
#	end
#end
	run!
end


