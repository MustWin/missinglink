require 'spec_helper'

describe Missinglink do

  ML_TEST_API_KEY = "9fakeapikeynumberinhereq"
  ML_TEST_TOKEN = "UFHRfakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttokeniI="
  ML_TEST_CREDS = { api_key: ML_TEST_API_KEY, token: ML_TEST_TOKEN }
  before do
    VCR.insert_cassette 'missinglink', record: :new_episodes, match_requests_on: [:method, :uri, :host, :path, :query, :body_as_json, :headers]
  end

  after do
    VCR.eject_cassette
  end

  context "#poll_surveys" do
    let(:survey) { Missinglink::Survey.new }

    it "should return nil if no credentials are provided" do
      Missinglink.poll_surveys.should be_nil
    end

    it "should attempt to update the attributes for the first or new survey by id" do
      survey.should_receive(:update_attributes).exactly(3).times
      Missinglink::Survey.should_receive(:first_or_create_by_sm_survey_id).exactly(3).times.and_return(survey)
      Missinglink.should_receive(:fetch_survey).exactly(3).times.with(survey, ML_TEST_CREDS)
      Missinglink.poll_surveys(ML_TEST_CREDS)
    end
  end

  context "#fetch_survey" do
    let(:survey) { Missinglink::Survey.new(sm_survey_id: 50144489) }

    it "should return nil if no credentials are provided" do
      Missinglink.fetch_survey(survey).should be_nil
    end

    it "should attempt to update the attributes of the survey with a lot of things" do
      survey.should_receive(:update_from_survey_details)
      Missinglink.fetch_survey(survey, ML_TEST_CREDS)
    end
  end

  context "#fetch_respondents" do
    let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }
    let(:survey_respondent_detail) { Missinglink::SurveyRespondentDetail.new(survey: survey, sm_respondent_id: 3131160696) }

    it "should return nil if no credentials are provided" do
      Missinglink.fetch_respondents(survey).should be_nil
    end

    it "should attempt to update the attributes for the first or new survey respondent by survey and id" do
      survey_respondent_detail.should_receive(:update_attributes)
      Missinglink::SurveyRespondentDetail.should_receive(:first_or_create_by_survey_details).with(survey.id, "3131160696").and_return(survey_respondent_detail)
      Missinglink.fetch_respondents(survey, ML_TEST_CREDS)
    end
  end

  context "#fetch_responses" do
    let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }

    it "should return nil if no credentials are provided" do
      Missinglink.fetch_responses(survey).should be_nil
    end

    it "should only send the respondent ids that are complete and have no surveys" do
      complete_srd = Missinglink::SurveyRespondentDetail.new(survey_id: survey.id, status: 'completed')
      pulled_srd = Missinglink::SurveyRespondentDetail.new(survey_id: survey.id, status: 'completed')
      pulled_srd.stub(:survey_responses => [Missinglink::SurveyResponse.new])
      Missinglink::SurveyRespondentDetail.stub(:where => [complete_srd, pulled_srd])

      Missinglink.should_receive(:fetch_response_answers).with(survey, [complete_srd], ML_TEST_CREDS)

      Missinglink.fetch_responses(survey, ML_TEST_CREDS)
    end
  end

  context "#fetch_response_answers" do
    let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }
    let(:survey_respondent_detail) { Missinglink::SurveyRespondentDetail.new(survey: survey, sm_respondent_id: 3131160696) }

    it "should return nil if no credentials are provided" do
      Missinglink.fetch_response_answers(survey, survey_respondent_detail).should be_nil
    end
  end
end
