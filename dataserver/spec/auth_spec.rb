
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "auth"))

describe "Creating a hashed password" do
	before :each do
		@secret = "wheedle"
		@password = BCrypt::Password.create(@secret, :cost => 4)
	end

	specify "should return a BCrypt::Password" do
		expect(@password).to be_an_instance_of(BCrypt::Password)
	end

end

describe "Testing Auth module" do
	before :all do
		@secret = "wheedle"
		@passwd_file = File.expand_path(File.join(File.dirname(__FILE__), "passwd.json"))
		@passwd_json = File.read(@passwd_file)
		@params = {
			:password => @secret,
			:email => "steeve.mccauley@gmail.com"
		}
	end

	specify "should load password spec sample file" do
		@passwd_data = Auth.load_users(@passwd_file)
		expect(@passwd_data).to be
	end

	specify "should find email user" do
		expect(Auth.find_by_email(@params[:email])).to be
	end

	specify "should login from params" do
		Auth.find_by_email(@params[:email])
		expect(Auth.login(@params)).to be_truthy
	end
end


