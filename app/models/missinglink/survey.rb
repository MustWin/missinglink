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

    def load_survey_details
      begin
        response = Connection.request('get_survey_details',
                                           { survey_id: sm_survey_id.to_s })
      rescue Exception => e
        puts "Exception raised when loading survey details for #{ self.inspect }.\n#{ e.inspect }"
        return
      end

      (puts "Error loading survey details for survey #{ self.inspect }." && return) unless response

      update_from_survey_details(response)

      response['pages'].each do |page|
        SurveyPage.parse(self, page)
      end

      return true
    end

    def load_respondents
      begin
        response = Connection.request('get_respondent_list',
                                      { survey_id: sm_survey_id.to_s })
      rescue Exception => e
        puts "Exception raised when loading survey respondents for #{ self.inspect }.\n#{ e.inspect }"
        return
      end

      (puts "Error loading responses for survey #{ self.inspect }" && return) unless response

      response['respondents'].each do |respondent|
        SurveyRespondentDetail.parse(self, respondent)
      end

      return true
    end

    def respondents_to_update
      completed_respondents = survey_respondent_details.completed
      completed_respondents.select { |r| r.survey_responses.empty? }
    end

    def load_response_details(respondents)
      respondents = [respondents] unless respondents.is_a? Array

      while (respondents.size > 0)
        ids = respondents.slice!(0, 100).map { |x| x.sm_respondent_id.to_s }
        begin
          response = Connection.request('get_responses',
                                        { survey_id: sm_survey_id.to_s,
                                          respondent_ids: ids })
        rescue Exception => e
          puts "Exception raised when loading response details for #{ self.inspect }.\n#{ e.inspect }"
          return
        end

        (puts "Error fetching response answers" && return) unless response

        response.each do |r|
          SurveyResponse.parse(self, r) unless r.nil?
        end
      end

      return true
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
