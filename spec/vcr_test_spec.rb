require 'spec_helper'
require 'typhoeus'

describe "VCR Tests" do
  before do
    VCR.insert_cassette 'missinglink', record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  it "should record the get_survey_list interaction" do
    request = typh_request('get_survey_list').tap { |x| x.run }
    response = JSON.parse(request.response.body)
    response.should_not be_nil
  end

  it "should record the get_survey_details interactions" do
    request = typh_request('get_survey_details', {survey_id: "50144489"}.to_json).tap { |x| x.run }
    request = typh_request('get_survey_details', {survey_id: "50144354"}.to_json).tap { |x| x.run }
    request = typh_request('get_survey_details', {survey_id: "50143846"}.to_json).tap { |x| x.run }
    response = JSON.parse(request.response.body)['data']
    response.should_not be_nil
  end

  it "should record the get_respondent_list interaction" do
    request = typh_request('get_respondent_list', {survey_id: "50144489"}.to_json).tap { |x| x.run }
    request = typh_request('get_respondent_list', {survey_id: "50144354"}.to_json).tap { |x| x.run }
    request = typh_request('get_respondent_list', {survey_id: "50143846"}.to_json).tap { |x| x.run }
    response = JSON.parse(request.response.body)['data']
    response.should_not be_nil
  end

  it "should recored the get_responses for specific respondents" do
    request = typh_request('get_responses', {survey_id: "50144489", respondent_ids: ["3131170764","3131170081","3131168491"] }.to_json).tap { |x| x.run }
    request = typh_request('get_responses', {survey_id: "50144354", respondent_ids: ["3131160696"] }.to_json).tap { |x| x.run }
    request = typh_request('get_responses', {survey_id: "50143846", respondent_ids: ["3131167482","3131158726","3131157843","3131156710"] }.to_json).tap { |x| x.run }
    response = JSON.parse(request.response.body)['data']
    response.should_not be_nil
  end
end

def typh_request(fragment, body = '{ }')
  sleep 0.5
  Typhoeus::Request.new(
    "https://api.surveymonkey.net/v2/surveys/#{fragment}",
    method: :post,
    params: { api_key: api_key },
    body: body,
    headers: { Authorization: "bearer #{token}", :"Content-Type" => "application/json" }
  )
end

def api_key
  "9fakeapikeynumberinhereq"
end

def token
  "UFHRfakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttokeniI="
end
