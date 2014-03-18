module Missinglink
  class SurveyAnswer < ActiveRecord::Base
    self.table_name = "survey_answers"

    belongs_to :survey_question

    def self.parse(question, hash)
      answer = SurveyAnswer.first_or_create_by_question_details(question.id, hash['answer_id'])

      answer.update_attributes({ position: hash['position'].to_i,
                                 text: hash['text'],
                                 answer_type: hash['type'],
                                 visible: hash['visible'],
                                 weight: hash['weight'],
                                 apply_all_rows: hash['apply_all_rows'],
                                 is_answer: hash['is_answer'] })

      answer.survey_question = question
      answer.save

      return answer
    end

    def self.first_or_create_by_question_details(question_id, sm_id)
      if new_answer = SurveyAnswer.find_by_survey_question_id_and_sm_answer_id(question_id, sm_id.to_i)
        return new_answer
      else
        return SurveyAnswer.create(survey_question_id: question_id, sm_answer_id: sm_id.to_i)
      end
    end
  end
end
