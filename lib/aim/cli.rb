module AIM
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class HathiTrust < Thor
      desc "set_digitizer", "sets digitizer for digifeeds items"
      long_desc <<~DESC
        Triggers the "Change Physical items information job" on the digifeeds
        set so that Statistics Note 1 has the value "umich". This will tell Google
        that Umich is the digitizer of the item. 
      DESC
      def set_digitizer
        start_time = Time.now.to_i
        AIM::HathiTrust::DigitizerSetter.configure
        AIM::HathiTrust::DigitizerSetter.new.run
        AIM::HathiTrust::DigitizerSetter.send_metrics(start_time)
      end
    end

    class StudentWorkers < Thor
      desc "expire_passwords", "expires student worker passwords"
      def expire_passwords
        AIM::StudentWorkers::PasswordExpirer.new.run
      end
    end

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

    desc "ht SUBCOMMAND", "commands related to the HathiTrust and Google Books project"
    subcommand "ht", HathiTrust

    desc "student_workers SUBCOMMAND", "commands related to student workers"
    subcommand "student_workers", StudentWorkers

    desc "sms SUBCOMMAND", "commands related to student workers"
    subcommand "sms", SMS
  end
end
