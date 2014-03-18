module Missinglink
  class SurveyPageQuestion < ActiveRecord::Base
    self.table_name = "survey_page_questions"

    belongs_to :survey_page
    belongs_to :survey_question
  end
end
