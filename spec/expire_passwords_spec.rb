require "spec_helper"

RSpec.describe PasswordExpirer do
  before(:each) do
    @user_json = fixture('user.json')
    @put_body = JSON.parse(@user_json)
    @put_body["force_password_change"] = "TRUE"
    @user =  "mlibrary.acct.testing1@gmail.com"
    @logger = instance_double(Logger, info: nil, error: nil)

  end
  subject do
    described_class.new([@user], @logger).run
  end
  it "forces a password change" do
    get_stub = stub_alma_get_request(url:"users/#{@user}", output: @user_json)    
    put_stub = stub_alma_put_request(url:"users/#{@user}", input: @put_body.to_json)

    expect(@logger).not_to receive(:error)
    expect(subject[:number_of_errors]).to eq(0)
    expect(get_stub).to have_been_requested
    expect(put_stub).to have_been_requested
  end
  it "logs an error on failed get and returns proper number of errors" do
    get_stub = stub_alma_get_request(url:"users/#{@user}", output: nil, status: 500)    
    put_stub = stub_alma_put_request(url:"users/#{@user}", input: @put_body.to_json)
    expect(@logger).to receive(:error)
    expect(subject[:number_of_errors]).to eq(1)
    expect(get_stub).to have_been_requested
    expect(put_stub).not_to have_been_requested
  end
  it "logs an error on failed put and returns proper number of errors" do
    get_stub = stub_alma_get_request(url:"users/#{@user}", output: @user_json)    
    put_stub = stub_alma_put_request(url:"users/#{@user}", input: @put_body.to_json, status: 500)
    expect(@logger).to receive(:error)
    expect(subject[:number_of_errors]).to eq(1)
    expect(get_stub).to have_been_requested
    expect(put_stub).to have_been_requested
  end
end
