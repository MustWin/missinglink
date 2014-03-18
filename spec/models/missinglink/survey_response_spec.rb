require 'spec_helper'

module Missinglink
  describe SurveyResponse do
    let(:survey_response) { SurveyResponse.new }

    context "#first_or_create_by_question_details" do
      it "should create and return a new record if there is no answer with the question or sm id" do
        SurveyResponse.stub(:find_by_survey_respondent_detail_id_and_survey_question_id => nil)
        lambda do
          new_page = SurveyResponse.first_or_create_by_respondent_and_question(10, 50)
          new_page.survey_respondent_detail_id.should == 10
          new_page.survey_question_id.should == 50
        end.should change(SurveyResponse, :count).by(1)
      end

      it "should just return the existing answer if it's found" do
        SurveyResponse.stub(:find_by_survey_respondent_detail_id_and_survey_question_id => survey_response)
        lambda do
          SurveyResponse.first_or_create_by_respondent_and_question(10, 50).should == survey_response
        end.should_not change(SurveyResponse, :count)
      end
    end
  end
end
