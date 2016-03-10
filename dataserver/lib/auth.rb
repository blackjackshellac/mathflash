#!/usr/bin/env ruby
#

require 'json'
require 'bcrypt'

#
# json file
# {
# steeve:{
# 	hash:
# 	full_name:
# 	email:
# },
# lissa: {
# 	hash:
# 	full_name:
# 	email:
# }
# }
#

module Auth
	@@auth_data = {}

	def self.read_json(file)
		File.read(file)
	rescue => e
		raise "Failed to read file #{file}: #{e.to_s}"
	end

	def self.parse_auth(json)
		@@auth_data = JSON.parse(json, :symbolize_names => true)
		@@auth_data
	rescue => e
		raise "Failed to parse json auth_data: #{e.to_s}"
	end

	def self.load_users(file)
		json=Auth.read_json(file)
		parse_auth(json)
	end

	def self.save_users(file)
		json=JSON.pretty_generate(@@auth_data)
		File.open(file, "w+") { |fd|
			fd.print json
		}
	rescue => e
		raise "Failed to save auth_data to #{file}: #{e.to_s}"
	end

	def self.find_by_email(email)
		puts @@auth_data.inspect
		@@auth_data.each_pair { |user,meta|
			next unless meta.key?(:email)
			return @@auth_data[user] if email.eql?(meta[:email])
		}
		return nil
	end

	def self.login(params)
		res = {
			:status=>false,
			:msg=>""
		}
		@user = find_by_email(params["email"])
		# user not found
		if @user.nil?
			res[:msg] = "User email not found"
			return res
		end

		@hash = BCrypt::Password.new(@user[:hash])
		res[:status] = @hash == params["password"]
		if res[:status]
			@user[:token] = BCrypt::Password.create(@hash)
			res[:msg] = "Ok"
			res[:token] = @user[:token]
		else
			res[:msg] = "Password mismatch"
		end
		return res
	end
end
