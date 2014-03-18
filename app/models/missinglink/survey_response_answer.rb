module Missinglink
  class SurveyResponseAnswer < ActiveRecord::Base
    self.table_name = "survey_response_answers"

    belongs_to :survey_response

    def self.parse(response, hash)
      answer = SurveyResponseAnswer.create({survey_response_id: response.id}.
                                              merge(prepare_answer_hash(hash)))

      return answer
    end

  private
    def self.prepare_answer_hash(hash)
      clean_hash = {}
      clean_hash['row_survey_answer_id'] = SurveyAnswer.find_by_sm_answer_id(hash['row'].to_i).id if (hash['row'] && hash['row'] != "0")
      clean_hash['col_survey_answer_id'] = SurveyAnswer.find_by_sm_answer_id(hash['col'].to_i).id if hash['col']
      clean_hash['col_choice_survey_answer_id'] = SurveyAnswer.find_by_sm_answer_id(hash['col_choice'].to_i).id if hash['col_choice']
      clean_hash['text'] = hash['text'] if hash['text']

      return clean_hash
    end
  end
end
