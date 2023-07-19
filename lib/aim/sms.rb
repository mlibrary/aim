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
        gauge :aim_send_sms_last_success, comment: "Time that Alma sms messages were successfully sent"
        gauge :aim_send_sms_num_messages_sent, comment: "Number of Alma sms messages sent in a job"
        gauge :aim_send_sms_num_messages_not_sent, comment: "Number of Alma sms messages that caused an error"
        gauge :aim_send_sms_num_messages_error, comment: "Number of Alma sms messages that were NOT successfully sent"
      end
      Yabeda.configure!
    end

    def self.send_metrics(results)
      Yabeda.aim_send_sms_num_messages_sent.set({}, results[:num_files_sent])
      Yabeda.aim_send_sms_num_messages_not_sent.set({}, results[:num_files_not_sent])
      Yabeda.aim_send_sms_num_messages_error.set({}, results[:num_files_error])
      Yabeda.aim_send_sms_last_success.set({}, results[:start_time])
      begin
        Yabeda::Prometheus.push_gateway.add(Yabeda::Prometheus.registry)
      rescue
        Logger.new($stdout).error("Failed to contact the push gateway")
      end
    end

    # For debugging purposes
    # See
    # https://www.twilio.com/docs/sms/api/message-resource?code-sample=code-read-list-all-messages&code-language=Ruby&code-sdk-version=6.x#read-multiple-message-resources
    # for things one might do with the client
    def self.twilio_client
      Twilio::REST::Client.new(ENV.fetch("TWILIO_ACCT_SID"), ENV.fetch("TWILIO_AUTH_TOKEN"))
    end

    def self.get_message_status(sid)
      message = twilio_client.messages(sid).fetch
      {
        status: message.status,
        sid: message.sid,
        to: message.to,
        body: message.body,
        date_created: message.date_created,
        date_sent: message.date_sent,
        error_code: message.error_code,
        error_message: message.error_message,
        full_message: message
      }
    end
  end
end
