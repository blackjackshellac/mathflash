#!/usr/bin/env ruby
#

require 'thread'
require 'sinatra'
require 'json'

configure {
	set :server, :puma
	set :port, 1962
	set :bind, '0.0.0.0'
	set :root, File.dirname(__FILE__)
}

helpers do
	$mathflash_data = "data/mathflash_data.json"
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

	def pre(data)
		data=JSON.pretty_generate(data) unless data.class == String
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
end

get '/' do
	  "Hello World"
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
get '/mathflash' do
	json=read_sync
	pre data_section(json)
end

get '/mathflash/global' do
	json=read_sync
	pre data_section(json, [:global])
end

get '/mathflash/global/options' do
	json=read_sync
	pre data_section(json, [:global,:options])
end

get '/mathflash/global/name' do
	json=read_sync
	pre data_section(json, [:global,:name])
end

get '/mathflash/names' do
	json = read_sync
	pre data_section(json, [:names]).keys
end

get '/mathflash/names/:name' do
	json = read_sync
	name = params['name']
	pre data_section(json, [:names, name.to_sym])
end

get '/mathflash/names/:name/options' do
	json = read_sync
	name = params['name']
	pre data_section(json, [:names, name.to_sym, :options])
end

get '/mathflash/names/:name/stats' do
	json = read_sync
	name = params['name']
	pre data_section(json, [:names, name.to_sym, :stats])
end


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


