require "canister"
require "semantic_logger"
require "date"

Services = Canister.new
S = Services

S.register(:app_name) {
  ENV["APP_NAME"] || "AIM"
}

S.register(:project_root) do
  File.absolute_path(File.join(__dir__, ".."))
end

S.register(:today_str) { Date.today.to_s }
S.register(:first_of_the_month) do
  Date.new(Date.today.year, Date.today.month, 1).to_s
end

# Hathifiles
S.register(:ht_host) { ENV["HT_HOST"] || "https://www.hathitrust.org" }
# S.register(:hf_db_username) { ENV["HATHIFILES_DB_USERNAME"] || "user" }
# S.register(:hf_db_password) { ENV["HATHIFILES_DB_PASSWORD"] || "password" }
# S.register(:hf_db_host) { ENV["HATHIFILES_DB_HOST"] || "hathifiles" }
# S.register(:hf_db_database) { ENV["HATHIFILES_DB_DATABASE"] || "hathifiles" }

S.register(:log_stream) do
  $stdout.sync = true
  $stdout
end

S.register(:logger) do
  SemanticLogger["aim #{S.app_name}"]
end

SemanticLogger.add_appender(io: S.log_stream, level: :info) unless ENV["APP_ENV"] == "test"
