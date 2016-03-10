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

	def self.load_users(file)
		json=File.read(file)
		@@auth_data = JSON.parse(json, :symbolize_names => true)
		@@auth_data
	end

	def self.save_users(file)
		json=JSON.pretty_generate(@@auth_data)
		#File.open(file, "w+") { |fd|
		#	fd.print json
		#}
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
		@user = find_by_email(params["email"])
		# user not found
		return nil if @user.nil?

		@hash = BCrypt::Password.new(@user[:hash])
		return @hash == params["password"]
	end
end
