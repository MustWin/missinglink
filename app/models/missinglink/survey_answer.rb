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

      if hash['items'] then
        hash['items'].each do |sub_item|
          SurveyAnswer.parse(question, sub_item)
        end
      end

      return answer
    end

    def self.first_or_create_by_question_details(question_id, sm_id)
      if new_answer = SurveyAnswer.find_by_survey_question_id_and_sm_answer_id(question_id, sm_id.to_i)
        return new_answer
      else
        return SurveyAnswer.create(survey_question_id: question_id, sm_answer_id: sm_id.to_i)
      end
    end

    def possible_responses
      strategy = survey_question.answer_strategy
      filtered = survey_question.possible_responses.select do |k,v|
        sra = SurveyResponseAnswer.find(v)
        if strategy == "answer_row_and_column_for_response" ||
           strategy == "answer_row_for_subquestion" ||
           strategy == "answer_row_column_choice_for_response"
          (sra.row_survey_answer_id == self.id)
        else
          true
        end
      end
      return filtered
    end
  end
end
