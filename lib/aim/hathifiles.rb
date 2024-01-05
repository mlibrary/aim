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
    end
  end
end
