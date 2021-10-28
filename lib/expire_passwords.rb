require 'alma_rest_client'
require 'logger'

class PasswordExpirer
  def initialize(users, logger=Logger.new(STDOUT), client = AlmaRestClient.client)
    @users = users
    @client = client
    @logger = logger
  end
  def run
    error_count = 0
    @logger.info("Started Expiring Student Worker Account Passwords")
    #log started password expirer
    @users.each do |uniqname|
      response = @client.get("/users/#{uniqname}")
      if response.code != 200
        @logger.error("Unable to get info about user: #{uniqname}")
        error_count = error_count+1
        next
      end
      body = response.parsed_response
      body["force_password_change"] = "TRUE"
      new_response = @client.put("/users/#{uniqname}", body: body.to_json)
      if new_response.code != 200
        @logger.error("Unable to update user: #{uniqname}")
        error_count = error_count+1
      else
        @logger.info("Forced password change for: #{uniqname}")
      end
    end
    @logger.info("Finished expiring student accounts.\nNumber of errors: #{error_count}")
    { number_of_errors: error_count }
    
  end
end
