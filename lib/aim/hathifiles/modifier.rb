module AIM
  module Hathifiles
    class Modifier
      attr_reader :scratch_dir
      def initialize(date:,
        scratch_dir: "/app/scratch/#{SecureRandom.alphanumeric(8)}",
        logger: S.logger,
        connection: HathifilesDatabase.new(S.ht_mysql_connection))

        @date_str = Date.parse(date).strftime("%Y%m%d")
        @scratch_dir = scratch_dir
        @hathifile_url = "#{S.ht_host}/files/hathifiles/#{hathifile}"
        @logger = logger
        @connection = connection
      end

      def run
        @logger.info("creating scratch directory: #{@scratch_dir}")
        Dir.mkdir(@scratch_dir) unless Dir.exist?(@scratch_dir)
        @logger.info("pull hathifile: #{@hathifile_url}")
        http_conn = Faraday.new do |builder|
          builder.adapter Faraday.default_adapter
        end
        response = http_conn.get @hathifile_url
        raise StandardError, "Did not successfully download #{@hathifile_url}" if response.status != 200
        File.binwrite("#{@scratch_dir}/#{hathifile}", response.body)

        command
      rescue => e
        @logger.error(e.message)
        raise e
      ensure
        @connection&.rawdb&.disconnect
        clean
      end

      def hathifile
      end

      def command
      end

      def clean
        @logger.info("removing scratch directory")
        FileUtils.remove_dir(@scratch_dir)
      end
    end
  end
end
