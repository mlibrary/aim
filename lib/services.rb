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

S.register(:scratch_dir) do
  ENV["SCRATCH_DIR"] || File.join(S.project_root, "scratch")
end

S.register(:today_str) { Date.today.to_s }
S.register(:first_of_the_month) do
  Date.new(Date.today.year, Date.today.month, 1).to_s
end

# Hathifiles
S.register(:ht_host) { ENV["HT_HOST"] || "https://www.hathitrust.org" }

S.register(:log_stream) do
  $stdout.sync = true
  $stdout
end

S.register(:log_level) do
  ENV["DEBUG"] ? :debug : :info
end

S.register(:logger) do
  SemanticLogger["aim #{S.app_name}"]
end

class ProductionFormatter < SemanticLogger::Formatters::Json
  # Leave out the pid
  def pid
  end

  # Leave out the timestamp
  def time
  end

  # Leave out environment
  def environment
  end

  # Leave out application (This would be Semantic Logger, which isn't helpful)
  def application
  end
end

S.register(:app_env) do
  ENV["APP_ENV"] || "development"
end

case S.app_env
when "production"
  SemanticLogger.add_appender(io: S.log_stream, level: S.log_level, formatter: ProductionFormatter.new)
when "development"
  SemanticLogger.add_appender(io: S.log_stream, level: S.log_level, formatter: :color)
end
