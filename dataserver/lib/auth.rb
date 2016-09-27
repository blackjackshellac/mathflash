#!/usr/bin/env ruby
#

require 'json'
require 'bcrypt'
require 'sqlite3'

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

class AuthError < StandardError

end

class AuthNoUser < StandardError

end

module Auth
	@@log = nil

	def self.set_logger(log)
		@@log = log
	end

	def self.read_json(file)
		File.read(file)
	rescue => e
		raise "Failed to read file #{file}: #{e.to_s}"
	end

	def self.create_user_data(params)
		h = {
			:user  => params[:user],
			:email => params[:email],
		}

		h[:token] = params[:token] if params.key?(:token)

		if params.key?(:passwd)
			h[:hash] = BCrypt::Password.create(params[:passwd])
		elsif params.key?(:hash)
			h[:hash] = params[:hash]
		else
			raise AuthError.new, __method__+"Missing :passwd or :hash"
		end

		h
	end

	def self.find_by_user_email(db, user, email)
		user_data = {}

		db.prepare("select * from users where user = :user OR email = :email LIMIT 1") { |stm|
			rs = stm.execute "user"=>user, "email"=>email
			rs.each { |row|
				user_data[:user] = row["user"]
				user_data[:hash] = row["hash"]
				user_data[:email] = row["email"]
				user_data[:uid] = row["uid"]
			}
		}

		if user_data.key?(:email)
			raise AuthError.new "email mismatch: #{email} != #{user_data[:email]}" unless email.eql?(user_data[:email])
		end

		return user_data
	end

	def self.find_by_user(db, user)
		user_data=find_by_user_email(db, user, nil)

		raise AuthNoUser.new, "User not found: #{user}" unless user_data[:user]

		return user_data 

	end

	def self.find_by_email(db, email)
		@@log.debug "db=#{db.inspect}"
		@@log.debug "email=#{email}"

		user_data=find_by_user_email(db, nil, email)

		raise AuthNoUser.new, "User data not found for email #{email}" unless user_data[:user]

		return user_data 
	end

	def self.create_token(user_data)
		hash=user_data[:hash]
		user=user_data[:user]
		time=(Time.now.to_f*1000000).to_s
		Digest::SHA256.hexdigest(user+hash+time) 
	rescue => e
		@@log.debug "create_token failed: #{e.to_s}"
	end

	def self.token_from_email(params)
		res = {
			:status=>false,
			:msg=>""
		}
		user_data = find_by_email(params[:db], params["email"])
		user_data[:token] = create_token(user_data)
		res[:token] = user_data[:token]
		res[:status] = true
		res
	end

	def self.logout(params)
		res = {
			:status=>false,
			:msg=>""
		}
		user_data = find_by_email(params[:db], params["email"])
		# user_data not found
		if user_data.nil?
			res[:msg] = "User email not found"
		else
			$log.error "missing params['token']" unless params.key?("token")
			if user_data.key?(:token)
				token = params["token"]||""
				$log.error "token mismatch #{token} != #{user_data[:token]}" unless token.eql?(user_data[:token])
				user_data.delete(:token)
			end
			res[:token] = nil
			res[:uid] = nil
			res[:status] = true
		end
		res
	end

	def self.login(params)
		res = {
			:status=>false,
			:msg=>""
		}
		user_data = find_by_email(params[:db], params["email"])
		# user not found
		if user_data.nil?
			res[:msg] = "User email not found"
			return res
		end

		password = BCrypt::Password.new(user_data[:hash])
		res[:status] = password == params["password"]
		raise "Password mismatch for #{user_data[:email]}" unless res[:status]

		user_data[:token] = create_token(user_data)
		res[:token] = user_data[:token]
		res[:uid] = user_data[:uid]
		res[:user] = user_data[:user]
		res[:email] = user_data[:email]

		return res
	end

	def self.upe(opts)
		user=opts[:user]
		passwd=opts[:passwd]
		email=opts[:email]
		return user,passwd,email
	end

	def self.add_user(opts)
		user,passwd,email = Auth::upe(opts)
		db = opts[:db]

		@@log.die "user name must be set" if user.nil?
		@@log.die "passwd string must be set" if passwd.nil?
		@@log.die "email must be set" if email.nil?
		@@log.die "db must be set" if db.nil?

		user_data=create_user_data(opts)
		@@log.debug "user_data = #{user_data.inspect}"
		hash = user_data[:hash]

		db.prepare("insert into users (user, email, hash) values (:user, :email, :hash)") { |stm|
			stm.execute "user"=>user, "email"=>email, "hash"=>hash
		}
	rescue SQLite3::ConstraintException => e
		@@log.error "#{__method__} failed: user #{user} already exists in database"
	rescue => e
		puts e.backtrace
		@@log.die "#{__method__} failed: "+e.to_s
	end


	def self.test_user(opts)
		user,passwd,email = Auth::upe(opts)

		@@log.die "passwd string must be set" if passwd.nil?
		@@log.die "user or email must be set" if email.nil? && user.nil?

		db = opts[:db]
		user_data = find_by_user_email(db, user, email)

		@@log.debug JSON.pretty_generate(user_data)

		raise "user #{user} or email #{email} not found" if user_data.empty?

		pw = BCrypt::Password.new(user_data[:hash])

		@@log.debug "pw = "+pw.inspect

		raise AuthError.new, "failed to authenticate user #{pw} != #{passwd}" unless pw == passwd

	end


end
