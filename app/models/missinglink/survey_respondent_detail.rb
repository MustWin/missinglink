module Missinglink
  class SurveyRespondentDetail < ActiveRecord::Base
    self.table_name = "survey_respondent_details"

    belongs_to :survey
    has_many :survey_responses
    has_many :survey_response_answers, through: :survey_responses

    scope :completed, -> { where(status: "completed") }

    def self.parse(survey, hash)
      srd = SurveyRespondentDetail.first_or_create_by_survey_details(survey.id, hash['respondent_id'])

      attrs = prepare_respondent_details(hash)
      srd.update_attributes(attrs)

      return srd
    end

    def self.first_or_create_by_survey_details(survey_id, sm_id)
      # spelling this one out more explicitly so it's easier to test
      if new_srd = SurveyRespondentDetail.find_by_survey_id_and_sm_respondent_id(survey_id, sm_id.to_i)
        return new_srd
      else
        return SurveyRespondentDetail.create(survey_id: survey_id, sm_respondent_id: sm_id.to_i)
      end
    end

  private
    def self.prepare_respondent_details(respondent_hash)
      hash = { collection_mode: respondent_hash['collection_mode'],
               custom_id: respondent_hash['custom_id'],
               email: respondent_hash['email'],
               first_name: respondent_hash['first_name'],
               last_name: respondent_hash['last_name'],
               ip_address: respondent_hash['ip_address'],
               status: respondent_hash['status'] || "completed",
               analysis_url: respondent_hash['analysis_url'] }

      (hash[:date_start] = Date.parse(respondent_hash['date_start'])) if respondent_hash['date_start']
      (hash[:date_modified] = Date.parse(respondent_hash['date_modified'])) if respondent_hash['date_modified']
      (hash[:collector_id] = respondent_hash['collector_id'].to_i) if respondent_hash['collector_id']

      return hash
    end
  end
end
