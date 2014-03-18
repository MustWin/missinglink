require 'spec_helper'

module Missinglink
  describe SurveyQuestion do
    let(:survey_question) { SurveyQuestion.new }

    context "#first_or_create_by_sm_id" do
      it "should create and return a new record if there is no question with the sm id" do
        SurveyQuestion.stub(:find_by_sm_question_id => nil)
        lambda do
          new_question = SurveyQuestion.first_or_create_by_sm_id(50)
          new_question.sm_question_id.should == 50
        end.should change(SurveyQuestion, :count).by(1)
      end

      it "should just return the existing question if it's found" do
        SurveyQuestion.stub(:find_by_sm_question_id => survey_question)
        lambda do
          SurveyQuestion.first_or_create_by_sm_id(50).should == survey_question
        end.should_not change(SurveyQuestion, :count)
      end
    end
  end
end
