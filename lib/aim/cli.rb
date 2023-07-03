module AIM
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class StudentWorkers < Thor
      desc "expire_passwords", "expires student worker passwords"
      def expire_passwords
        AIM::StudentWorkers::PasswordExpirer.new.run
      end
    end

    desc "student_workers SUBCOMMAND", "commands related to student workers"
    subcommand "student_workers", StudentWorkers
  end
end
