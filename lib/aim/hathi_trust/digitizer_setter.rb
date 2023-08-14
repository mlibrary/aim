module AIM
  module HathiTrust
    class DigitizerSetter
      def self.configure
        ::Yabeda.configure do
          gauge :aim_hathi_trust_set_digitizer_last_success, comment: "Start time of the last Set Digitizer Job that successfully finished."
        end
        Yabeda.configure!
      end

      def self.send_metrics(start_time)
        Yabeda.aim_hathi_trust_set_digitizer_last_success.set({}, start_time)
        begin
          Yabeda::Prometheus.push_gateway.add(Yabeda::Prometheus.registry)
        rescue
          Logger.new($stdout).error("Failed to contact the push gateway")
        end
      end

      def initialize(logger: Logger.new($stdout))
        @logger = logger
      end

      def run
        @logger.info("Fetching digifeeds_metadata set id")
        sets_resp = AlmaRestClient.client.get_all(url: "/conf/sets", record_key: "set", query: {"q" => "name~digifeeds_metadata"})
        if sets_resp.status != 200
          @logger.error("Failed to fetch set")
          abort
        end

        set_id = sets_resp
          .body["set"]
          .filter_map { |x| x["id"] if x["name"] == "digifeeds_metadata" }
          .first

        @logger.info("Set Id: #{set_id}")

        @logger.info("Sending Change Physical Item Job to set the Digitizer to Umich for Digifeeds")
        resp = AlmaRestClient.client.post("/conf/jobs/#{ENV.fetch("CHANGE_PHYSICAL_ITEM_INFORMATION_JOB_ID")}?op=run", body: body(set_id: set_id))
        @logger.info resp.body
        if resp.status == 200
          @logger.info("Finished Sending Change Physical Items job")
        else
          @logger.error("Failed to send job")
        end
      end

      def body(set_id:)
        {
          "parameter" => params(set_id: set_id).map do |name, value|
            {
              "name" => {"value" => name, "desc" => name},
              "value" => value
            }
          end
        }
      end

      def params(set_id:)
        {
          "STATISTICS_NOTE_1_value" => digitizer,
          "STATISTICS_NOTE_1_selected" => true,
          "set_id" => set_id,
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
