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
  end
end
