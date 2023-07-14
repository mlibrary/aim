module AIM
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class HathiTrust < Thor
      desc "set_digitizer", "sets digitizer for digifeeds items"
      long_desc <<~DESC
        Triggers the "Change Physical items information job" on the digifeeds
        set so that Statistics Note 3 has the value "umich". This will tell Google
        that Umich is the digitizer of the item. 
      DESC
      def set_digitizer
        AIM::HathiTrust::DigitizerSetter.new.run
      end
    end

    class StudentWorkers < Thor
      desc "expire_passwords", "expires student worker passwords"
      def expire_passwords
        AIM::StudentWorkers::PasswordExpirer.new.run
      end
    end

    desc "ht SUBCOMMAND", "commands related to the HathiTrust and Google Books project"
    subcommand "ht", HathiTrust

    desc "student_workers SUBCOMMAND", "commands related to student workers"
    subcommand "student_workers", StudentWorkers
  end
end
