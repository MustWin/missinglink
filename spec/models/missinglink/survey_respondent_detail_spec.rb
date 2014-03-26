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

    context "#response_to_question" do
      let(:question) { SurveyQuestion.new }
      let(:response) { SurveyResponse.new }
      let(:answer1)  { SurveyAnswer.new(text: "Answer 1") }
      let(:answer2)  { SurveyAnswer.new(text: "Answer 2") }
      let(:answer3)  { SurveyAnswer.new(text: "Answer 3") }

      it "should return nil if the question was not answered" do
        srd.stub_chain("survey_responses.find_by_survey_question_id").and_return(nil)
        srd.response_to_question(question).should be_nil
      end

      context "should return a plaintext response for each question type that was responded to" do
        before(:each) do
          srd.stub_chain("survey_responses.find_by_survey_question_id").and_return(response)
          allow(SurveyAnswer).to receive(:find).with(10) { answer1 }
          allow(SurveyAnswer).to receive(:find).with(20) { answer2 }
          allow(SurveyAnswer).to receive(:find).with(30) { answer3 }
        end

        it "for first_survey_response_answer_text" do
          sra = SurveyResponseAnswer.new(text: "Value")
          response.survey_response_answers << sra
          question.stub(answer_strategy: "first_survey_response_answer_text")
          srd.response_to_question(question).should == "Value"
        end

        it "for answer_row_match_for_survey_response_answer_text" do
          sra1 = SurveyResponseAnswer.new(row_survey_answer_id: 10)
          sra2 = SurveyResponseAnswer.new(row_survey_answer_id: 20, text: "Something")
          response.survey_response_answers << [sra1, sra2]
          question.stub(answer_strategy: "answer_row_match_for_survey_response_answer_text")
          srd.response_to_question(question).should == "Answer 1; Answer 2: Something"
        end

        it "for row_column_survey_response_answers_and_text" do
          sra1 = SurveyResponseAnswer.new(row_survey_answer_id: 10, col_survey_answer_id: 20 )
          sra2 = SurveyResponseAnswer.new(text: "Something")
          response.survey_response_answers << [sra1, sra2]
          question.stub(answer_strategy: "row_column_survey_response_answers_and_text")
          srd.response_to_question(question).should == "Answer 1: Answer 2; Other: Something"
        end

        it "for row_column_and_choice_survey_response_answers_and_text" do
          sra1 = SurveyResponseAnswer.new(row_survey_answer_id: 10, col_survey_answer_id: 20, col_choice_survey_answer_id: 30 )
          sra2 = SurveyResponseAnswer.new(text: "Something")
          response.survey_response_answers << [sra1, sra2]
          question.stub(answer_strategy: "row_column_and_choice_survey_response_answers_and_text")
          srd.response_to_question(question).should == "Answer 1, Answer 2: Answer 3; Other: Something"
        end
      end
    end
  end
end
