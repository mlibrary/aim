require "spec_helper"
RSpec.describe "CLI" do
  it "shows only the commands related to the app name" do
    with_modified_env APP_NAME: "hathifiles" do
      output = `exe/aim help`
      expect(output).to include("hathifiles")
      expect(output).not_to include("sms")
    end
  end
end
