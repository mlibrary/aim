require "spec_helper"

RSpec.describe PasswordExpirer do
  it "forces a password change" do
    user_json = fixture('user.json')
    put_body = JSON.parse(user_json)
    put_body["force_password_change"] = "TRUE"
    user =  "mlibrary.acct.testing1@gmail.com"

    get_stub = stub_alma_get_request(url:"users/#{user}", output: user_json)    
    put_stub = stub_alma_put_request(url:"users/#{user}", input: put_body.to_json)
    described_class.new([user]).run
    expect(get_stub).to have_been_requested
    expect(put_stub).to have_been_requested
  end
end
