require 'spec_helper'

describe Missinglink::Connection do
  context "credentialing" do
    before(:each) do
      Missinglink::Connection.credential_hash = {}
    end

    it "should have a publicly accessible method to see if credentials were provided" do
      Missinglink::Connection.credentials_provided?.should be_false
    end

    it "should not have an api key or token to start" do
      Missinglink::Connection.credential_hash = {}
      Missinglink::Connection.instance_variable_get("@credential_hash")[:api_key].should be_nil
      Missinglink::Connection.instance_variable_get("@credential_hash")[:token].should be_nil
      Missinglink::Connection.credentials_provided?.should be_false
    end

    it "should insist no credentials provided if only one of two pieces are present" do
      Missinglink::Connection.credential_hash = { api_key: "key" }
      Missinglink::Connection.credentials_provided?.should be_false
      Missinglink::Connection.credential_hash = { token: "token" }
      Missinglink::Connection.credentials_provided?.should be_false
    end

    it "should say it has its credentials if both api key and token are provided" do
      Missinglink::Connection.credential_hash = ML_TEST_CREDS
      Missinglink::Connection.credentials_provided?.should be_true
    end
  end

  context "#request" do
    it "should not make a Typheous request unless there are credentials" do
      Missinglink::Connection.stub(credentials_provided?: false)
      Typhoeus::Request.should_not receive(:new)
      Missinglink::Connection.request('get_survey_list')
    end
  end
end
