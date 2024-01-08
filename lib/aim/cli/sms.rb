module AIM
  class CLI
    class SMS < Thor
      option :nosend, type: :boolean, desc: "don't actually send with the Twilio API"
      desc "send", "sends sms messages that were deposited by Alma"
      long_desc <<~DESC
        Looks in the sms folder for sms message files deposited by alma. Sends
        the message via the Twilio API. Moves the message into the processed
        folder within the sms folder on the sftp server.
      DESC
      def send
        start_time = Time.now.to_i

        AIM::SMS.configure
        params = {}
        if options[:nosend]
          params[:sender] = AIM::SMS::Sender.new(AIM::SMS::FakeTwilioClient.new)
        end

        results = AIM::SMS::Processor.new(**params).run
        results[:start_time] = start_time

        AIM::SMS.send_metrics(results)
      end
    end
  end
end

module AIM
  class CLI
    desc "sms SUBCOMMAND", "commands related to student workers"
    subcommand "sms", SMS
  end
end
