module Missinglink
  class SurveyQuestion < ActiveRecord::Base
    self.table_name = "survey_questions"

    has_many :survey_page_questions
    has_many :survey_pages, through: :survey_page_questions
    has_many :survey_answers
    has_many :survey_responses

    def self.parse(page, hash)
      question = SurveyQuestion.first_or_create_by_sm_id(hash['question_id'])

      question.update_attributes({ heading: hash['heading'],
                                   position: hash['position'].to_i,
                                   type_family: hash['type']['family'],
                                   type_subtype: hash['type']['subtype'] })
      question.survey_pages = [page]
      question.save

      hash['answers'].each do |answer|
        SurveyAnswer.parse(question, answer)
      end

      return question.reload
    end

    def self.first_or_create_by_sm_id(sm_id)
      if question = SurveyQuestion.find_by_sm_question_id(sm_id)
        return question
      else
        return SurveyQuestion.create(sm_question_id: sm_id)
      end
    end
  end
end
