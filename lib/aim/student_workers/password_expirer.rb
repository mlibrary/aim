module AIM
  module StudentWorkers
    class PasswordExpirer
      def initialize(logger = Logger.new($stdout), client = AlmaRestClient.client)
        @client = client
        @logger = logger
      end

      def run
        users_response = @client.get_all(url: "/conf/sets/#{ENV.fetch("STUDENT_USERS_SET_ID")}/members", record_key: "member")
        if users_response.status != 200
          @logger.error("Unable to retrieve student users set")
          raise StandardError, "Unable to retrieve student users set"
        end
        error_count = 0
        @logger.info("Started Expiring Student Worker Account Passwords")
        # log started password expirer
        users_response.body["member"].each do |user|
          uniqname = user["id"]
          response = @client.get("/users/#{uniqname}")
          if response.status != 200
            @logger.error("Unable to get info about user: #{uniqname}")
            error_count += 1
            next
          end
          body = response.body
          body["force_password_change"] = "TRUE"
          new_response = @client.put("/users/#{uniqname}", body: body.to_json)
          if new_response.status != 200
            @logger.error("Unable to update user: #{uniqname}")
            error_count += 1
          else
            @logger.info("Forced password change for: #{uniqname}")
          end
        end
        @logger.info("Finished expiring student accounts.\nNumber of errors: #{error_count}")
        {number_of_errors: error_count}
      end
    end
  end
end
