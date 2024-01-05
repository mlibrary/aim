require "canister"
require "semantic_logger"

Services = Canister.new
S = Services

S.register(:ht_host) { ENV["HT_HOST"] }
S.register(:ht_mysql_connection) { ENV["HT_MYSQL_CONNECTION"] }

S.register(:app_name) {
  ENV["APP_NAME"] || "AIM"
}

S.register(:log_stream) do
  $stdout.sync = true
  $stdout
end

S.register(:logger) do
  SemanticLogger[S.app_name]
end

SemanticLogger.add_appender(io: S.log_stream, level: :info) unless ENV["APP_ENV"] == "test"
