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

    def load_questions
      unless Missinglink.credentials_provided?
        puts "Please provide a hash with api_key and token to fetch survey questions." && return
      end
    end

    def update_from_survey_details(response = {})
      return nil if response.nil? || response.empty? || response['title'].nil?

      self.update_attributes({date_created: DateTime.parse(response['date_created']),
                              date_modified: DateTime.parse(response['date_modified']),
                              title: response['title']['text'],
                              language_id: response['language_id'].to_i,
                              nickname: response['nickname'],
                              title_enabled: response['title']['enabled'],
                              title_text: response['title']['text']})
    end
  end
end
