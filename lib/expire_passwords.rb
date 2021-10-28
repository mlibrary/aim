require 'alma_rest_client'

class PasswordExpirer
  def initialize(users, client = AlmaRestClient.client)
    @users = users
    @client = client
  end
  def run
    #log started password expirer
    @users.each do |uniqname|
      response = @client.get("/users/#{uniqname}")
      if response.code != 200
        #log error
        next
      end
      body = response.parsed_response
      body["force_password_change"] = "TRUE"
      new_response = @client.put("/users/#{uniqname}", body: body.to_json)
      if new_response.code != 200
        #log error
      else
        #log success
      end
    end
  end
end
