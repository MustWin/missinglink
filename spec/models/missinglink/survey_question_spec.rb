require 'pry'
require 'spec_helper'

module Missinglink
  describe SurveyQuestion do
    let(:survey_question) { SurveyQuestion.new }
    let(:survey_page) { SurveyPage.new }
    let(:hash) { { "answers" => [],
                   "type" => { "subtype" => "essay",
                               "family" => "open_ended" },
                   "position" => 4,
                   "heading" => "Open Ended, Essay",
                   "question_id" => "630844131" } }

    context "#parse" do
      before(:each) do
        SurveyQuestion.stub(:first_or_create_by_sm_id => survey_question)
      end

      it "should grab the first question that matches the sm_id, or create it if need be" do
        SurveyQuestion.should_receive(:first_or_create_by_sm_id).with("630844131")
        SurveyQuestion.parse(survey_page, hash)
      end

      it "should update the question attributes as necessary" do
        survey_question.should_receive(:update_attributes).with({ heading: "Open Ended, Essay",
                                                                  position: 4,
                                                                  type_family: "open_ended",
                                                                  type_subtype: "essay"})
        SurveyQuestion.parse(survey_page, hash)
      end

      it "sets the survey page for the question" do
        survey_question.should_receive(:survey_pages=).with([survey_page])
        SurveyQuestion.parse(survey_page, hash)
      end

      it "parses each answer" do
        answer_hash = hash.merge("answers" => ["1","2"])
        SurveyAnswer.should_receive(:parse).exactly(2).times
        SurveyQuestion.parse(survey_page, answer_hash)
      end
    end

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

    context "search interfaces" do
      subject { survey_question }
      let(:sra1) { SurveyResponseAnswer.create(text: "sra1",
                                               row_survey_answer_id: 10,
                                               col_survey_answer_id: 11,
                                               col_choice_survey_answer_id: 12) }
      let(:sra2) { SurveyResponseAnswer.create(text: nil,
                                               row_survey_answer_id: 20,
                                               col_survey_answer_id: 21,
                                               col_choice_survey_answer_id: 22) }
      let(:sra3) { SurveyResponseAnswer.create(text: "sra3",
                                               row_survey_answer_id: 30,
                                               col_survey_answer_id: 31,
                                               col_choice_survey_answer_id: 32) }
      let(:sra4) { SurveyResponseAnswer.create(text: "sra3",
                                               row_survey_answer_id: 10,
                                               col_survey_answer_id: 21,
                                               col_choice_survey_answer_id: 32) }
      let(:sra5) { SurveyResponseAnswer.create(text: "sra2",
                                               row_survey_answer_id: 20,
                                               col_survey_answer_id: 21,
                                               col_choice_survey_answer_id: 32) }
      let(:sra6) { SurveyResponseAnswer.create(text: "sra2",
                                               row_survey_answer_id: 20,
                                               col_survey_answer_id: 21,
                                               col_choice_survey_answer_id: 32) }
      let(:sra7) { SurveyResponseAnswer.create(text: "sra7",
                                               row_survey_answer_id: nil,
                                               col_survey_answer_id: nil,
                                               col_choice_survey_answer_id: nil) }
      before(:each) do
        [10, 11, 12, 20, 21, 22, 30, 31, 32].each do |n|
          allow(SurveyAnswer).to receive(:find).with(n) { SurveyAnswer.new(text: n.to_s) }
        end
      end

      context "#possible_responses" do
        context "should return a style of answer finding based on the type and subtype" do
          it "for first_survey_response_answer_text" do
            subject.stub(answer_strategy: "first_survey_response_answer_text")
            subject.stub(survey_response_answers: [sra1, sra2, sra3, sra4])
            subject.possible_responses.should == { "sra1" => sra1.id, "sra3" => sra3.id }
          end

          it "for answer_row_for_response" do
            subject.stub(answer_strategy: "answer_row_for_response")
            subject.stub(survey_response_answers: [sra1, sra2, sra3])
            subject.possible_responses(true).should == { "10" => sra1.id,
                                                         "20" => sra2.id,
                                                         "30" => sra3.id,
                                                         "10: sra1" => sra1.id,
                                                         "30: sra3" => sra3.id }
            subject.possible_responses.should == { "10" => sra1.id,
                                                   "20" => sra2.id,
                                                   "30" => sra3.id }
          end

          it "for answer_row_and_column_for_response" do
            subject.stub(answer_strategy: "answer_row_and_column_for_response")
            subject.stub(survey_response_answers: [sra1, sra2, sra3, sra7])
            subject.possible_responses(true).should == { "10: 11" => sra1.id,
                                                         "20: 21" => sra2.id,
                                                         "30: 31" => sra3.id,
                                                         "Other: sra7" => sra7.id }
            subject.possible_responses.should == { "10: 11" => sra1.id,
                                                   "20: 21" => sra2.id,
                                                   "30: 31" => sra3.id }
          end

          it "for answer_row_column_choice_for_response" do
            subject.stub(answer_strategy: "answer_row_column_choice_for_response")
            subject.stub(survey_response_answers: [sra1, sra2, sra4, sra7])
            subject.possible_responses(true).should == { "10, 11: 12" => sra1.id,
                                                         "20, 21: 22" => sra2.id,
                                                         "10, 21: 32" => sra4.id,
                                                         "Other: sra7" => sra7.id }
            subject.possible_responses.should == { "10, 11: 12" => sra1.id,
                                                   "20, 21: 22" => sra2.id,
                                                   "10, 21: 32" => sra4.id }
          end
        end
      end # possible_responses

      context "#similar_repsonse_answers" do
        context "should find similar non-other answers based on question answer strategy" do
          it "for first_survey_response_answer_text" do
            subject.stub(answer_strategy: "first_survey_response_answer_text")
            subject.stub(survey_response_answers: [sra1, sra2, sra3, sra4])
            subject.similar_response_answers(sra3).should == [sra3, sra4]
          end

          it "for answer_row_for_response" do
            subject.stub(answer_strategy: "answer_row_for_response")
            subject.stub(survey_response_answers: [sra1, sra2, sra3, sra4, sra5])
            subject.similar_response_answers(sra1).should == [sra1, sra4]
            subject.similar_response_answers(sra2).should == [sra2, sra5]
          end

          it "for answer_row_and_column_for_response" do
            subject.stub(answer_strategy: "answer_row_and_column_for_response")
            subject.stub(survey_response_answers: [sra1, sra2, sra3, sra4, sra5])
            subject.similar_response_answers(sra1).should == [sra1]
            subject.similar_response_answers(sra2).should == [sra2, sra5]
          end

          it "for answer_row_column_choice_for_response" do
            subject.stub(answer_strategy: "answer_row_column_choice_for_response")
            subject.stub(survey_response_answers: [sra1, sra2, sra3, sra4, sra5, sra6])
            subject.similar_response_answers(sra1).should == [sra1]
            subject.similar_response_answers(sra5).should == [sra5, sra6]
          end
        end

        it "should find similar other-based answers regardless of strategy" do
          subject.stub(survey_response_answers: [sra1, sra2, sra3, sra4, sra5, sra6])
          subject.similar_response_answers(sra1, true).should == [sra1]
          subject.similar_response_answers(sra3, true).should == [sra3, sra4]
          subject.similar_response_answers(sra4, true).should == [sra3, sra4]
        end
      end # similar_repsonse_answers

      context "#question_parts" do
        it "should return nil if there are no answers for the question" do
          subject.question_parts.should be_nil
        end

        context "by question type" do
          before(:each) do
            sr = SurveyResponse.new
            subject.stub(survey_response_answers: [sra1, sra2])
          end

          it "should return nil for first_survey_response_answer_text" do
            subject.stub(answer_strategy: "first_survey_response_answer_text")
            subject.question_parts.should be_nil
          end

          it "should return nil for answer_row_for_response" do
            subject.stub(answer_strategy: "answer_row_for_response")
            subject.question_parts.should be_nil
          end

          it "should return the row answers for answer_row_and_column_for_response" do
            subject.stub(answer_strategy: "answer_row_and_column_for_response")
            subject.question_parts.should == { "10" => 10, "20" => 20 }
          end

          it "should return the row answers for answer_row_column_choice_for_response" do
            subject.stub(answer_strategy: "answer_row_column_choice_for_response")
            subject.question_parts.should == { "10" => 10, "20" => 20 }
          end

          it "should return nil for none" do
            subject.stub(answer_strategy: "none")
            subject.question_parts.should be_nil
          end
        end
      end
    end # search interfaces
  end # survey question
end
