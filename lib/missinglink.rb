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
      fetch_survey(survey)
    end
  end

  def fetch_survey(survey)
    response = Connection.request('get_survey_details',
                                       { survey_id: survey.sm_survey_id.to_s })
    (puts "Error fetching survey." && return) unless response

    survey.update_from_survey_details(response)

    response['pages'].each do |page|
      SurveyPage.parse(survey, page)
    end
  end

  def fetch_respondents(survey)
    unless Connection.credentials_provided?
      puts "Please provide a hash with api_key and token to fetch survey respondents." && return
    end

    response = Connection.request('get_respondent_list',
                                          { survey_id: survey.sm_survey_id.to_s })
    (puts "Error fetching respondents." && return) unless response

    response['respondents'].each do |respondent|
      SurveyRespondentDetail.parse(survey, respondent)
    end

    fetch_responses(survey.reload)
  end

  def fetch_responses(survey)
    completed_respondents = SurveyRespondentDetail.where(survey_id: survey.id,
                                               status: "completed")
    respondents_to_pull = completed_respondents.select { |r| r.survey_responses.empty? }
    fetch_response_answers(survey, respondents_to_pull)
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
