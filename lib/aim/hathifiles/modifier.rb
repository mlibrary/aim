module AIM
  module Hathifiles
    class Modifier
      attr_reader :scratch_dir
      def initialize(date: nil, file_name: nil,
        scratch_dir: File.join(S.scratch_dir, SecureRandom.alphanumeric(8)),
        logger: S.logger,
        connection: Hathifiles.connection,
        delta_update_class: HathifilesDatabase::DeltaUpdate)
        @hathifile = file_name
        @date_str = Date.parse(date).strftime("%Y%m%d") unless date.nil?
        @scratch_dir = scratch_dir
        @hathifile_url = "#{S.ht_host}/files/hathifiles/#{hathifile}"
        @logger = logger
        @connection = connection
        @delta_update_klass = delta_update_class
        @milemarker = Milemarker.new(name: "loading hathifiles rows", batch_size: 10_000)
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
        @delta_update_klass.new(
          connection: @connection,
          hathifile: "#{@scratch_dir}/#{hathifile}",
          output_directory: @scratch_dir
        ).run do |records_inserted|
          @milemarker.increment records_inserted
          @milemarker.on_batch do
            S.logger.info "load_hathifiles_rows", total: @milemarker.count, batch_size: @milemarker.last_batch_size,
              batch_load_seconds: @milemarker.last_batch_seconds,
              batch_load_rate: @milemarker.batch_rate, overall_load_rate: @milemarker.total_rate
          end
        end
      end

      def clean
        @logger.info("removing scratch directory")
        FileUtils.remove_dir(@scratch_dir)
      end
    end
  end
end

module AIM
  module Hathifiles
    class Updater < Modifier
      def hathifile
        @hathifile || "hathi_upd_#{@date_str}.txt.gz"
      end
    end
  end
end

module AIM
  module Hathifiles
    class Full < Modifier
      def hathifile
        @hathifile || "hathi_full_#{@date_str}.txt.gz"
      end
    end
  end
end
