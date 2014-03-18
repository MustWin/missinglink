module Missinglink
  class SurveyPage < ActiveRecord::Base
    self.table_name = "survey_pages"

    belongs_to :survey
    has_many :survey_page_questions
    has_many :survey_questions, through: :survey_page_questions

    def self.parse(survey, hash)
      page = first_or_create_by_survey_details(survey.id, hash['page_id'])
      page.update_attributes({heading: hash['heading'],
                              sub_heading: hash['sub_heading']})


      hash['questions'].each do |question|
        SurveyQuestion.parse(page, question)
      end

      return page.reload
    end

    def self.first_or_create_by_survey_details(survey_id, sm_id)
      # spelling this one out more explicitly so it's easier to test
      if new_page = SurveyPage.find_by_survey_id_and_sm_page_id(survey_id, sm_id.to_i)
        return new_page
      else
        return SurveyPage.create(survey_id: survey_id, sm_page_id: sm_id.to_i)
      end
    end
  end
end
