require "hathifiles_database"
require "date"
require "fileutils"
require "securerandom"
require "faraday"
require "milemarker"

require "aim/hathifiles/modifier"

module AIM
  module Hathifiles
    class << self
      def catch_up(date)
        start_date = Date.parse(date)
        start_date.upto(Date.today) do |date|
          Updater.new(date: date.to_s).run
        end
      end

      def connection
        HathifilesDatabase.new(
          logger: S.logger
        )
      end

      def sequel_connection
        connection.rawdb
      end

      def full(date)
        Full.new(date: date).run
      end

      def update(date)
        Updater.new(date: date).run
      end

      def update_for_files(files, updater = Updater)
        files.sort.each do |file_name|
          updater.new(file_name: file_name).run
        end
      end

      def update_for_file(file_name)
        Updater.new(file_name: file_name).run
      end

      def setup
        Hathifiles.connection
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
