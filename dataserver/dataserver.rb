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

do helpers
	$mathflash_json = "data/mathflash_options.json"
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
			read_save_sync($mathflash_json)
		rescue => e
			halt 500 "Failed to read mathflash data: #{$mathflash_json}"+e.to_s
		end
	end

	def write_sync
		begin
			read_save_sync($mathflash_json, { :save=> true } )
		rescue => e
			halt 500 "Failed to write mathflash data: #{$mathflash_json}"+e.to_s
		end
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
	read_sync
end

get '/mathflash/options' do
	json = read_sync
	begin
		data=JSON.parse(json, :symbolize_names => true)
		names = data[:options].keys.to_json
		puts names
		names
	rescue => e
		"Failed to parse mathflash data: #{$mathflash_json}"+e.to_s
	end
end

get '/mathflash/stats' do
	json = read_sync
	json
end

#get '/mathflash/stats/:name' do
#	name=params['name']
#	halt 404, "name parameter not found!" if name.nil?
#	json=nil
#	begin
#		json=read_save_sync($mathflash_json)
#	rescue => e
#		halt 404, "Failed to read mathflash data: #{$mathflash_json}"+e.to_s
#	end
#	puts "name=#{name}"
#	begin
#		data=JSON.parse(json, :symbolize_names => true)
#		stats=data[:stats]
#		halt 500, "No stats in #{$mathflash_json}: #{json}" if stats.nil?
#		halt 500, "No stats for name=#{name}: #{data.to_json}" unless stats.key?(name.to_sym)
#		stats = stats[name.to_sym]
#		puts stats
#		stats	
#	rescue => e
#		"Failed to parse mathflash data: #{$mathflash_json}"+e.to_s
#	end
#end

#{
#    "options": {
#        "default": {
#            "left_max": "10",
#            "right_max": "10",
#            "number_max": "50",
#            "timeout_max": "0"
#        },
#        "etienne": {
#            "left_max": "12",
#            "right_max": "12",
#            "number_max": "50",
#            "timeout_max": "0"
#        },
#        "enzo": {
#            "left_max": "12",
#            "right_max": "4",
#            "number_max": "25",
#            "timeout_max": "0"
#        },
#        "steeve": {
#            "left_max": "12",
#            "right_max": "12",
#            "number_max": "10",
#            "timeout_max": "0"
#        },
#        "lissa": {
#            "left_max": "20",
#            "right_max": "12",
#            "number_max": "5",
#            "timeout_max": "0"
#        }
#    },
#    "name": "steeve",
#    "stats": {
#        "steeve": {
#            "+": {
#                "x": [
#                    1455655468,
#                    1455655532,
#                    1455657038
#                ],
#                "y0": [
#                    100,
#                    100,
#                    80
#                ],
#                "y1": [
#                    2.4,
#                    1.5,
#                    2.1
#                ]
#            }
#        }
#    }
#}
#
