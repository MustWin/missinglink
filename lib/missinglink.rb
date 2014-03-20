require 'pry'
require "missinglink/engine"
require "missinglink/connection"

module Missinglink
  include Connection
  extend self

  def poll_surveys
    response = Connection.request('get_survey_list')
    (puts "Error polling surveys" && return) unless response

    response['surveys'].each do |s|
      survey = Survey.first_or_create_by_sm_survey_id(s['survey_id'].to_i)
      survey.update_attributes(analysis_url: s['analysis_url'])
      survey.load_survey_details
    end
  end

  def fetch_respondents(survey)
    survey.load_respondents

    fetch_responses(survey.reload)
  end

  def fetch_responses(survey)
    fetch_response_answers(survey, survey.respondents_to_update)
  end

  def fetch_response_answers(survey, respondents)
    respondents = [respondents] unless respondents.is_a? Array
    while (respondents.size > 0)
      ids = respondents.slice!(0, 100).map { |x| x.sm_respondent_id.to_s }
      response = Connection.request('get_responses',
                                         { survey_id: survey.sm_survey_id.to_s,
                                           respondent_ids: ids })

      (puts "Error fetching response answers" && return) unless response

      response.each do |r|
        SurveyResponse.parse(survey, r) unless r.nil?
      end
    end
  end
end
