module AIM
  class CLI
    class Hathifiles < Thor
      desc "catchup", "applies updates to the hathifiles from start_date up to today; Default start_date is today"
      option :start_date, type: :string, default: S.today_str
      def catch_up
        AIM::Hathifiles.catch_up(options[:start_date])
      end

      desc "full", "reloads full hathifiles db for given date; default date is the first of the current month"
      option :date, type: :string, default: S.first_of_the_month
      def full
        AIM::Hathifiles.full(options[:date])
      end

      desc "update", "updates the hathifiles db for given date; default date is today"
      option :date, type: :string, default: S.today_str
      def update
        start_time = Time.now.to_i
        AIM::Hathifiles.configure_update_metrics
        AIM::Hathifiles.update(options[:date])
        AIM::Hathifiles.send_metrics(start_time)
      end

      desc "setup", "recreates the tables for the hathifiles database"
      def setup
        AIM::Hathifiles.setup
      end
    end
  end
end

module AIM
  class CLI
    desc "hathifiles SUBCOMMAND", "commands related to the Hathifiles database"
    subcommand "hathifiles", Hathifiles
  end
end
