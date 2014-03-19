require 'spec_helper'

module Missinglink
  describe Survey do

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

    context "#load_questions" do
      let(:survey) { Missinglink::Survey.new(sm_survey_id: 50144489) }

      it "should return nil unless Missinglink has its credentials provided" do
        Missinglink.stub(credentials_provided?: false)
        Missinglink::Connection.should_not receive(:request)
        survey.load_questions.should be_nil
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
