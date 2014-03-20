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
    return if survey.load_respondents.nil?

    fetch_responses(survey.reload)
  end

  def fetch_responses(survey)
    fetch_response_answers(survey, survey.respondents_to_update)
  end

  def fetch_response_answers(survey, respondents)
    survey.load_response_details(respondents)
  end
end
