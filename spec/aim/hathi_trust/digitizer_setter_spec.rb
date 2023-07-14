RSpec.describe AIM::HathiTrust::DigitizerSetter do
  it "triggers a change physical items information job;" do
    logger_double = instance_double(Logger, info: nil)
    body =
      {"parameter" =>
       [
         {"name" => {"value" => "STATISTICS_NOTE_3_value", "desc" => "STATISTICS_NOTE_3_value"}, "value" => "umich"},
         {"name" => {"value" => "STATISTICS_NOTE_3_selected", "desc" => "STATISTICS_NOTE_3_selected"}, "value" => true},
         {"name" => {"value" => "set_id", "desc" => "set_id"}, "value" => ENV.fetch("DIGIFEEDS_SET_ID")},
         {"name" => {"value" => "job_name", "desc" => "job_name"}, "value" => "Change Physical items information - set digitizer to Umich"}
       ]}

    request = stub_alma_post_request(url: "conf/jobs/#{ENV.fetch("CHANGE_PHYSICAL_ITEM_INFORMATION_JOB_ID")}?op=run", input: body)
    described_class.new(logger: logger_double).run
    expect(request).to have_been_requested
  end
end
