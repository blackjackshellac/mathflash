#!/usr/bin/env ruby
#
# passwd - manage passwords
#

ME = File.basename($PROGRAM_NAME, '.rb')
MD = File.expand_path(File.dirname(__FILE__))
LIB = File.join(MD, "lib")

require 'optparse'
require 'json'

require File.join(LIB, "auth")
require File.join(LIB, "logger")
require File.join(LIB, "o_parser")

$log = Logger::set_logger(STDOUT, Logger::DEBUG)

DB_MATHFLASH_DB = File.join(MD, "db")
DB_MATHFLASH_DATA = File.join(DB_MATHFLASH_DB, "mathflash_data.sqlite3")
DB_MATHFLASH_INIT = File.join(DB_MATHFLASH_DB, "mathflash_init.sql")

$opts = {
	:user => nil,
	:passwd => nil,
	:email => nil,
	:logger => $log,
	:save => false,
	:test => false,
	:passfile => File.join(MD, "db/passwd.json"),
	:dbfile => DB_MATHFLASH_DATA,
	:db => nil
}

$opts = OParser.parse($opts, nil) { |opts|
	opts.on('-u', '--user NAME') { |name|
		$opts[:user]=name
	}

	opts.on('-f', '--file PASSFILE', "Password file #{$opts[:passfile]}") { |file|
		$opts[:passfile] = file
	}

	opts.on('-p', '--passwd PASSWD', String, "Passwd to set") { |passwd|
		$opts[:passwd] = passwd
	}

	opts.on('-e', '--email EMAIL', String, "Email for user") { |email|
		$opts[:email] = email
	}

	opts.on('-s', '--[no-]save', "Save password update to database") { |save|
		$opts[:save] = save
	}

	opts.on('-t', '--[no-]test', "Test password against database") { |test|
		$opts[:test] = test
	}
}

$log.debug "Opening database #{$opts[:dbfile]}"
$opts[:db]=SQLite3::Database.new( $opts[:dbfile], :results_as_hash=>true )

$log.debug "Initializing database from #{DB_MATHFLASH_INIT}"
sql_init=File.read(DB_MATHFLASH_INIT)
$opts[:db].execute(sql_init) { |row|
	puts row.inspect
}

Auth::set_logger($log)

if $opts[:test]
	#Auth::test($opts)
	Auth::test_user($opts)
else
	#Auth::add($opts)
	Auth::add_user($opts)
end

