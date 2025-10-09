require "rspec"
require "byebug"
require "webmock/rspec"
require "simplecov"
require "climate_control"
require "httpx/adapters/webmock"

SimpleCov.start

require File.expand_path "../../lib/aim.rb", __FILE__

RSpec.configure do |config|
  include AlmaRestClient::Test::Helpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Set the APP_NAME to "test" so that the
  config.around(:each) do |example|
    ClimateControl.modify APP_NAME: "test" do
      example.run
    end
  end
end

def fixture(path)
  File.read("./spec/fixtures/#{path}")
end

def with_modified_env(options = {}, &block)
  ClimateControl.modify(options, &block)
end
