require 'spec_helper'

module Missinglink
  describe SurveyRespondentDetail do
    let(:srd) { SurveyRespondentDetail.new }

    context "#first_or_create_by_survey_details" do
      it "should create and return a new record if there is no respondent with the survey or sm id" do
        SurveyRespondentDetail.stub(:find_by_survey_id_and_sm_respondent_id => nil)
        lambda do
          new_srd = SurveyRespondentDetail.first_or_create_by_survey_details(10, 50)
          new_srd.survey_id.should == 10
          new_srd.sm_respondent_id.should == 50
        end.should change(SurveyRespondentDetail, :count).by(1)
      end

      it "should just return the existing respondent if it's found" do
        SurveyRespondentDetail.stub(:find_by_survey_id_and_sm_respondent_id => srd)
        lambda do
          SurveyRespondentDetail.first_or_create_by_survey_details(10, 50).should == srd
        end.should_not change(SurveyRespondentDetail, :count)
      end
    end
  end
end
