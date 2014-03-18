module Missinglink
  class Survey < ActiveRecord::Base
    self.table_name = "surveys"

    has_many :survey_pages
    has_many :survey_questions, through: :survey_pages
    has_many :survey_respondent_details

    def self.first_or_create_by_sm_survey_id(sm_id)
      # spelling this one out more explicitly so it's easier to test
      if new_survey = Survey.find_by_sm_survey_id(sm_id.to_i)
        return new_survey
      else
        return Survey.create(sm_survey_id: sm_id.to_i)
      end
    end
  end
end
