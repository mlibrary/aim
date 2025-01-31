module AIM
  class CLI < Thor
    def self.exit_on_failure?
      true
    end
  end
end

["hathifiles", "hathi_trust", "student_workers", "sms"].each do |subcommand|
  if ["test", "AIM", subcommand].include?(S.app_name)
    require "aim/cli/#{subcommand}"
  end
end
