require "json"
require "twilio-ruby"
require "telephone_number"
require "fileutils"
require "logger"
require "yabeda"
require "yabeda/prometheus"

require "sftp"

require "aim/sms/sender"

module AIM
  module SMS
    def self.configure
      ::Yabeda.configure do
        gauge :aim_send_alma_sms_last_success, comment: "Time that Alma sms messages were successfully sent"
        gauge :aim_send_alma_sms_num_messages_sent, comment: "Number of Alma sms messages sent in a job"
        gauge :aim_send_alma_sms_num_messages_not_sent, comment: "Number of Alma sms messages that caused an error"
        gauge :aim_send_alma_sms_num_messages_error, comment: "Number of Alma sms messages that were NOT successfully sent"
      end
      Yabeda.configure!
    end

    def self.send_metrics(results)
      Yabeda.aim_send_alma_sms_num_messages_sent.set({}, results[:num_files_sent])
      Yabeda.aim_send_alma_sms_num_messages_not_sent.set({}, results[:num_files_not_sent])
      Yabeda.aim_send_alma_sms_num_messages_error.set({}, results[:num_files_error])
      Yabeda.aim_send_alma_sms_last_success.set({}, results[:start_time])
      begin
        Yabeda::Prometheus.push_gateway.add(Yabeda::Prometheus.registry)
      rescue
        Logger.new($stdout).error("Failed to contact the push gateway")
      end
    end
  end
end
