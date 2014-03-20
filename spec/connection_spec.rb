require 'spec_helper'

describe Missinglink::Connection do
  let(:subject) { Missinglink::Connection }

  context "credentialing" do
    before(:each) do
      subject.credential_hash = {}
    end


    it "should have a publicly accessible method to see if credentials were provided" do
      subject.credentials_provided?.should be_false
    end

    it "should not have an api key or token to start" do
      subject.credential_hash = {}
      subject.instance_variable_get("@credential_hash")[:api_key].should be_nil
      subject.instance_variable_get("@credential_hash")[:token].should be_nil
      subject.credentials_provided?.should be_false
    end

    it "should insist no credentials provided if only one of two pieces are present" do
      subject.credential_hash = { api_key: "key" }
      subject.credentials_provided?.should be_false
      subject.credential_hash = { token: "token" }
      subject.credentials_provided?.should be_false
    end

    it "should say it has its credentials if both api key and token are provided" do
      subject.credential_hash = ML_TEST_CREDS
      subject.credentials_provided?.should be_true
    end
  end

  context "#request" do
    it "should not make a Typheous request unless there are credentials" do
      subject.stub(credentials_provided?: false)
      Typhoeus::Request.should_not receive(:new)
      subject.request('get_survey_list')
    end
  end
end
