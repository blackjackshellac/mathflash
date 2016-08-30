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
	@@log = nil
	@@auth_data = nil
	@@passwd_file = nil

	def self.set_logger(log)
		@@log = log
	end

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
		@@passwd_file = file
	end

	def self.save_users
		raise "auth data not loaded, must call load_users" if @@passwd_file.nil? || @@auth_data.nil?
		json=JSON.pretty_generate(@@auth_data)
		File.open(@@passwd_file, "w+") { |fd|
			fd.print json
		}
	rescue => e
		raise "Failed to save auth_data to #{file}: #{e.to_s}"
	end

	def self.save_user(user, passwd, email)
		suser=user.to_sym
		@@auth_data[suser]={
			:user  => user,
			:hash  => BCrypt::Password.create(passwd),
			:email => email
		}
	end

	def self.find_by_user(user)
		suser=user.to_sym
		return @@auth_data[suser]
	end

	def self.find_by_email(email)
		puts @@auth_data.inspect
		@@auth_data.each_pair { |user,meta|
			next unless meta.key?(:email)
			return @@auth_data[user] if email.eql?(meta[:email])
		}
		return nil
	end

	def self.token_from_hash(hash)
		Digest::SHA256.hexdigest(hash)
	end

	def self.token_from_email(params)
		res = {
			:status=>false,
			:msg=>""
		}
		user_data = find_by_email(params["email"])
		# user_data not found
		if user_data.nil?
			res[:msg] = "User email not found"
		else
			user_data[:token] = token_from_hash(user_data[:hash])
			res[:token] = user_data[:token]
			res[:status] = true
		end
		res
	end

	def self.login(params)
		res = {
			:status=>false,
			:msg=>""
		}
		user_data = find_by_email(params["email"])
		# user not found
		if user_data.nil?
			res[:msg] = "User email not found"
			return res
		end

		password = BCrypt::Password.new(user_data[:hash])
		res[:status] = password == params["password"]
		if res[:status]
			user_data[:token] = token_from_hash(user_data[:hash])
			res[:token] = user_data[:token]
		else
			res[:msg] = "Password mismatch"
		end
		return res
	end

	def self.upe(opts)
		user=opts[:user]
		passwd=opts[:passwd]
		email=opts[:email]
		return user,passwd,email
	end

	def self.add(opts)
		user,passwd,email = Auth::upe(opts)

		@@log.die "user name must be set" if user.nil?
		@@log.die "passwd string must be set" if passwd.nil?
		@@log.die "email must be set" if email.nil?

		save_user(user, passwd, email)

		@@log.debug "User=#{user}"
		@@log.debug JSON.pretty_generate(@@auth_data[suser])
		return unless opts[:save]
		Auth::save_users
	end

	def self.test(opts)
		user,passwd,email = Auth::upe(opts)

		@@log.die "passwd string must be set" if passwd.nil?

		user_data=nil
		if !user.nil?
			user_data = find_by_user(user)
		elsif !email.nil?
			user_data = find_by_email(email)
		else
			$log.die "must specify either user or email"
		end

		raise "user_data not found" if user_data.nil?

		@@log.debug JSON.pretty_generate(user_data)

		pw = BCrypt::Password.new(user_data[:hash])

		raise "failed to authenticate user" unless pw == passwd

	end

end
