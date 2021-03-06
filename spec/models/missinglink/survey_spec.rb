require 'spec_helper'

module Missinglink
  describe Survey do
    before do
      VCR.insert_cassette 'missinglink', record: :new_episodes, match_requests_on: [:method, :uri, :host, :path, :query, :body_as_json, :headers]
    end

    before(:each) do
      Missinglink::Connection.credential_hash = ML_TEST_CREDS
    end

    after do
      VCR.eject_cassette
    end

    context "#find_or_create_by_sm_survey_id" do
      let(:survey) { Survey.new }
      it "should create and return a new record if there is no survey with the sm_id" do
        Survey.stub(:find_by_sm_survey_id => nil)
        lambda do
          Survey.first_or_create_by_sm_survey_id(10).sm_survey_id.should == 10
        end.should change(Survey, :count).by(1)
      end

      it "should just return the existing survey if it's found" do
        Survey.stub(:find_by_sm_survey_id => survey)
        lambda do
          Survey.first_or_create_by_sm_survey_id(10).should == survey
        end.should_not change(Survey, :count)
      end
    end

    context "#load_survey_details" do
      let(:survey) { Missinglink::Survey.new(sm_survey_id: 50144489) }

      it "should return nil unless Missinglink has its credentials provided" do
        Missinglink::Connection.stub(credentials_provided?: false)
        survey.load_survey_details.should be_nil
      end

      it "should not attempt to update any details unless there are credentials" do
        Missinglink::Connection.stub(credentials_provided?: false)
        survey.should_not receive(:update_from_survey_details)
        survey.load_survey_details
      end

      it "should update details with a proper response" do
        SurveyPage.stub(:parse)
        survey.should receive(:update_from_survey_details)
        survey.load_survey_details
      end

      it "should take each page returned and attempt to parse it" do
        Missinglink::Connection.stub(request: { 'pages' => [1, 2, 3] })
        SurveyPage.should_receive(:parse).exactly(3).times
        survey.load_survey_details
      end
    end

    context "#load_respondents" do
      let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }

      it "should return nil unelss Missinglink has its credentials provided" do
        Missinglink::Connection.stub(credentials_provided?: false)
        survey.load_respondents.should be_nil
      end

      it "should not parse any respondent information without a respose" do
        Missinglink::Connection.stub(credentials_provided?: false)
        SurveyRespondentDetail.should_not receive(:parse)
        survey.load_respondents
      end

      it "should parse respondent detail for however many responses there are" do
        Missinglink::Connection.stub(request: { 'respondents' => [1, 1, 1] })
        SurveyRespondentDetail.should receive(:parse).with(survey, 1).exactly(3).times
        survey.load_respondents
      end
    end

    context "#respondents_to_update" do
      let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }

      it "should return an array of all completed survey respondent details without any survey responses" do
        completed_empty_respondent = SurveyRespondentDetail.new
        completed_empty_respondent.stub(survey_responses: [])
        completed_finished_respondent = SurveyRespondentDetail.new
        completed_finished_respondent.stub(survey_responses: ["item"])

        survey.stub_chain(:survey_respondent_details, :completed) { [completed_empty_respondent, completed_finished_respondent] }
        survey.respondents_to_update.should == [completed_empty_respondent]
      end
    end

    context "#load_response_details" do
      let(:survey) { Missinglink::Survey.create(sm_survey_id: 50144354) }
      let(:survey_respondent_detail) { Missinglink::SurveyRespondentDetail.new(survey: survey, sm_respondent_id: 3131160696) }

      it "should return nil unless Missinglink has its credentials provided" do
        Missinglink::Connection.stub(credentials_provided?: false)
        SurveyResponse.stub(:parse)
        survey.load_response_details([survey_respondent_detail]).should be_nil
      end

      it "should send a single request with all respondent IDs if there are under 100 and parse each" do
        respondents = [survey_respondent_detail] * 4
        Missinglink::Connection.should_receive(:request) { [0]*4 }.exactly(1).times
        SurveyResponse.should_receive(:parse).exactly(4).times
        survey.load_response_details(respondents)
      end

      it "should send a request for every group of 100" do
        respondents = [survey_respondent_detail] * 104
        Missinglink::Connection.should_receive(:request) { [1] }.exactly(2).times
        SurveyResponse.stub(:parse)
        survey.load_response_details(respondents)
      end

      it "should work for just one even if it's not an array" do
        Missinglink::Connection.should_receive(:request) { [1] }.exactly(1).times
        SurveyResponse.stub(:parse)
        survey.load_response_details(survey_respondent_detail)
      end
    end

    context "#update_from_survey_details" do
      let(:survey) { Survey.new }
      it "should not update any attributes if an empty hash or nothing is passed in" do
        survey.should_not receive(:update_attributes)
        survey.update_from_survey_details
        survey.update_from_survey_details({})
      end

      it "should not update any attributes if the hash does not have a title key" do
        survey.should_not receive(:update_attributes)
        survey.update_from_survey_details({ erm: "fake" })
      end

      it "should update attributes from the response" do
        sample_date = DateTime.now.to_s
        response = { 'date_created' => sample_date,
                     'date_modified' => sample_date,
                     'title' => { 'text' => "title text",
                                  'enabled' => true },
                     'language_id' => "1",
                     'nickname' => "nickname" }

        survey.update_from_survey_details(response)
        survey.date_created.should == DateTime.parse(sample_date)
        survey.date_modified.should == DateTime.parse(sample_date)
        survey.title.should == "title text"
        survey.language_id.should == 1
        survey.nickname.should == "nickname"
        survey.title_enabled.should be_true
        survey.title_text.should == "title text"
      end
    end
  end
end
