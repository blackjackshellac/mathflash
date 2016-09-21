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
#            "count": "50",
#            "timeout": "0"
#        },
#        "etienne": {
#            "left_max": "12",
#            "right_max": "12",
#            "count": "50",
#            "timeout": "0"
#        },
#        "enzo": {
#            "left_max": "12",
#            "right_max": "4",
#            "count": "25",
#            "timeout": "0"
#        },
#        "steeve": {
#            "left_max": "12",
#            "right_max": "12",
#            "count": "10",
#            "timeout": "0"
#        },
#        "lissa": {
#            "left_max": "20",
#            "right_max": "12",
#            "count": "5",
#            "timeout": "0"
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
