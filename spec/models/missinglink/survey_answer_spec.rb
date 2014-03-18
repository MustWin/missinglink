require 'spec_helper'

module Missinglink
  describe SurveyAnswer do
    let(:survey_answer) { SurveyAnswer.new }

    context "#first_or_create_by_question_details" do
      it "should create and return a new record if there is no answer with the question or sm id" do
        SurveyAnswer.stub(:find_by_survey_question_id_and_sm_answer_id => nil)
        lambda do
          new_answer = SurveyAnswer.first_or_create_by_question_details(10, 50)
          new_answer.survey_question_id.should == 10
          new_answer.sm_answer_id.should == 50
        end.should change(SurveyAnswer, :count).by(1)
      end

      it "should just return the existing answer if it's found" do
        SurveyAnswer.stub(:find_by_survey_question_id_and_sm_answer_id => survey_answer)
        lambda do
          SurveyAnswer.first_or_create_by_question_details(10, 50).should == survey_answer
        end.should_not change(SurveyAnswer, :count)
      end
    end
  end
end
