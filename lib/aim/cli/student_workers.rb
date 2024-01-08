module AIM
  class CLI
    class StudentWorkers < Thor
      desc "expire_passwords", "expires student worker passwords"
      def expire_passwords
        AIM::StudentWorkers::PasswordExpirer.new.run
      end
    end
  end
end

module AIM
  class CLI
    desc "student_workers SUBCOMMAND", "commands related to student workers"
    subcommand "student_workers", StudentWorkers
  end
end
