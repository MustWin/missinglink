module Missinglink
  class SurveyResponse < ActiveRecord::Base
    self.table_name = "survey_responses"

    belongs_to :survey_respondent_detail
    belongs_to :survey_question
    has_many :survey_response_answers

    def self.parse(survey, hash)
      respondent = SurveyRespondentDetail.find_by_sm_respondent_id(hash['respondent_id'].to_i)
      hash['questions'].each do |question_hash|
        question = SurveyQuestion.find_by_sm_question_id(question_hash['question_id'])
        response = SurveyResponse.first_or_create_by_respondent_and_question(respondent.id, question.id)
        question_hash['answers'].each do |answer_hash|
          SurveyResponseAnswer.parse(response, answer_hash)
        end
      end
    end

    def self.first_or_create_by_respondent_and_question(respondent_id, question_id)
      if new_response = SurveyResponse.find_by_survey_respondent_detail_id_and_survey_question_id(respondent_id.to_i, question_id.to_i)
        return new_response
      else
        return SurveyResponse.create(survey_respondent_detail_id: respondent_id.to_i,
                                     survey_question_id: question_id.to_i)
      end
    end
  end
end
