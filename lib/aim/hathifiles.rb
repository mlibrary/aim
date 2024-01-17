require "hathifiles_database"
require "date"
require "fileutils"
require "securerandom"
require "faraday"

require "aim/hathifiles/modifier"
require "aim/hathifiles/updater"
require "aim/hathifiles/full"

module AIM
  module Hathifiles
    class << self
      def catch_up(date)
        start_date = Date.parse(date)
        start_date.upto(Date.today) do |date|
          Updater.new(date: date.to_s).run
        end
      end

      def full(date)
        Full.new(date: date).run
      end

      def update(date)
        Updater.new(date: date).run
      end

      def setup
        HathifilesDatabase.new(S.ht_mysql_connection)
          .recreate_tables!
      end

      def configure_update_metrics
        ::Yabeda.configure do
          gauge :aim_hathifiles_update_last_success, comment: "Start time of the last Hathifiles Update Job that successfully finished."
        end
        Yabeda.configure!
      end

      def send_metrics(start_time)
        Yabeda.aim_hathifiles_update_last_success.set({}, start_time)
        begin
          Yabeda::Prometheus.push_gateway.add(Yabeda::Prometheus.registry)
        rescue
          S.logger.error("Failed to contact the push gateway")
        end
      end
    end
  end
end
