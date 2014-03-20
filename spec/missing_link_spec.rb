require 'spec_helper'

describe Missinglink do
  before do
    VCR.insert_cassette 'missinglink', record: :new_episodes, match_requests_on: [:method, :uri, :host, :path, :query, :body_as_json, :headers]
  end

  before(:each) do
    Missinglink::Connection.credential_hash = ML_TEST_CREDS
  end

  after do
    VCR.eject_cassette
  end

  context "#poll_surveys" do
    let(:survey) { Missinglink::Survey.new }

    it "should return nil if no credentials are provided" do
      Missinglink::Connection.stub(credentials_provided?: false)
      Missinglink.poll_surveys.should be_nil
    end

    it "should attempt to update the attributes for the first or new survey by id" do
      survey.should_receive(:update_attributes).exactly(3).times
      Missinglink::Survey.should_receive(:first_or_create_by_sm_survey_id).exactly(3).times.and_return(survey)
      survey.should_receive(:load_survey_details).exactly(3).times
      Missinglink.poll_surveys
    end
  end

  context "#fetch_respondents" do
    let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }
    let(:survey_respondent_detail) { Missinglink::SurveyRespondentDetail.new(survey: survey, sm_respondent_id: 3131160696) }

    it "should return nil if no credentials are provided" do
      Missinglink::Connection.stub(credentials_provided?: false)
      Missinglink.fetch_respondents(survey).should be_nil
    end

    it "should attempt to update the attributes for the first or new survey respondent by survey and id" do
      survey_respondent_detail.should_receive(:update_attributes)
      Missinglink::SurveyRespondentDetail.should_receive(:first_or_create_by_survey_details).with(survey.id, "3131160696").and_return(survey_respondent_detail)
      Missinglink.fetch_respondents(survey)
    end
  end

  context "#fetch_responses" do
    let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }

    it "should only send the respondent ids that are complete and have no surveys" do
      complete_srd = Missinglink::SurveyRespondentDetail.new(survey_id: survey.id, status: 'completed')
      pulled_srd = Missinglink::SurveyRespondentDetail.new(survey_id: survey.id, status: 'completed')
      pulled_srd.stub(:survey_responses => [Missinglink::SurveyResponse.new])
      Missinglink::SurveyRespondentDetail.stub(:where => [complete_srd, pulled_srd])

      Missinglink.should_receive(:fetch_response_answers).with(survey, [complete_srd])

      Missinglink.fetch_responses(survey)
    end
  end

  context "#fetch_response_answers" do
    let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }
    let(:survey_respondent_detail) { Missinglink::SurveyRespondentDetail.new(survey: survey, sm_respondent_id: 3131160696) }

    it "should return nil if no credentials are provided" do
      Missinglink::Connection.stub(credentials_provided?: false)
      Missinglink.fetch_response_answers(survey, survey_respondent_detail).should be_nil
    end
  end
end
