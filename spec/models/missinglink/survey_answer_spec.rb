require 'spec_helper'

module Missinglink
  describe SurveyAnswer do
    let(:survey_question) { SurveyQuestion.new }
    let(:survey_answer) { SurveyAnswer.new }
    let(:hash) { { "answer_id" => "7303942788",
                 "text" => "Menu 1",
                 "position" => 1,
                 "type" => "col",
                 "visible" => true,
                 "weight" => 1,
                 "apply_all_rows" => false,
                 "is_answer" => false } }
     let(:item_hash) { { "items" => [{ "answer_id" => "7303942789",
                                       "position" => 1,
                                       "type" => "col_choice",
                                       "text" => "Col Choice 1" },
                                     { "answer_id" => "7303942790",
                                       "position" => 2,
                                       "type" => "col_choice",
                                       "text" => "Col Choice 2" }] } }

    context "#parse" do
      before(:each) { SurveyAnswer.stub(first_or_create_by_question_details: survey_answer) }

      it "attempts to update the first or new answer object" do
        SurveyAnswer.should_receive(:first_or_create_by_question_details).with(anything(), "7303942788")
        SurveyAnswer.parse(survey_question, hash)
      end

      it "updates the appropriate attributes" do
        survey_answer.should_receive(:update_attributes).with({ position: 1,
                                                                text: "Menu 1",
                                                                answer_type: "col",
                                                                visible: true,
                                                                weight: 1,
                                                                apply_all_rows: false,
                                                                is_answer: false })
        SurveyAnswer.parse(survey_question, hash)
      end

      it "sets the question for the survey answer" do
        survey_answer.stub(:update_attributes)
        survey_answer.should_receive(:survey_question=).with(survey_question)
        SurveyAnswer.parse(survey_question, hash)
      end

      it "should attempt to parse the sub answers" do
        survey_answer.stub(:update_attributes)
        SurveyAnswer.should_receive(:parse).exactly(3).times.and_call_original
        SurveyAnswer.parse(survey_question, hash.merge(item_hash))
      end
    end

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
