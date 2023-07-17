module AIM
  module HathiTrust
    class DigitizerSetter
      def initialize(logger: Logger.new($stdout))
        @logger = logger
      end

      def run
        @logger.info("Sending Change Physical Item Job to set the Digitizer to Umich for Digifeeds")
        resp = AlmaRestClient.client.post("/conf/jobs/#{ENV.fetch("CHANGE_PHYSICAL_ITEM_INFORMATION_JOB_ID")}?op=run", body: body)
        @logger.info resp.body
        if resp.status == 200
          @logger.info("Finished Sending Change Physical Items job")
        else
          @logger.error("Failed to send job")
        end
      end

      def body
        {
          "parameter" => params.map do |name, value|
            {
              "name" => {"value" => name, "desc" => name},
              "value" => value
            }
          end
        }
      end

      def params
        {
          "STATISTICS_NOTE_1_value" => digitizer,
          "STATISTICS_NOTE_1_selected" => true,
          "set_id" => ENV.fetch("DIGIFEEDS_SET_ID"),
          "job_name" => job_name
        }
      end

      def digitizer
        "umich"
      end

      def job_name
        "Change Physical items information - set digitizer to Umich"
      end
    end
  end
end
