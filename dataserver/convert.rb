#!/usr/bin/env ruby
#

require 'json'

$mathflash_json = "data/mathflash_options.json"

json = File.read($mathflash_json)
old=JSON.parse(json, :symbolize_names=>true)
options=old[:options]
stats=old[:stats]||{}

$stderr.puts "Converting old data file to new format"
new={
	:global=>{
		:options=>options[:default],
		:name=>old[:name]
	},
	:names=>{}
}

options.each_pair { |name,value|
	$stderr.puts name
	ns=stats[name.to_sym]||{}
	new[:names][name.to_sym] = {
		:options=>value,
		:stats=>ns
	}
}

puts JSON.pretty_generate(new)


# new data format
#
# global
# 	name
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
