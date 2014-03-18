require "missinglink/engine"
require 'typhoeus'

module Missinglink
  extend self

  def poll_surveys(credential_hash = { api_key: nil, token: nil })
    unless (api_key = credential_hash[:api_key]) && (token = credential_hash[:token])
      puts "Please provide a hash with api_key and token to poll surveys."
      return
    end

    response = JSON.parse(typh_request('get_survey_list', api_key, token).tap {|x| x.run}.response.body)['data']['surveys']
    response.each do |s|
      survey = Survey.first_or_create_by_sm_survey_id(s['survey_id'].to_i)
      survey.update_attributes(analysis_url: s['analysis_url'])
      fetch_survey(survey, credential_hash)
    end
  end

  def fetch_survey(survey, credential_hash = { api_key: nil, token: nil })
    unless (api_key = credential_hash[:api_key]) && (token = credential_hash[:token])
      puts "Please provide a hash with api_key and token to fetch surveys."
      return
    end

    request = typh_request('get_survey_details', api_key, token, {survey_id: survey.sm_survey_id.to_s}.to_json).tap { |x| x.run }
    response = JSON.parse(request.response.body)['data']

    survey.update_attributes({date_created: DateTime.parse(response['date_created']),
                              date_modified: DateTime.parse(response['date_modified']),
                              title: response['title']['text'],
                              language_id: response['language_id'].to_i,
                              nickname: response['nickname'],
                              title_enabled: response['title']['enabled'],
                              title_text: response['title']['text']})

    response['pages'].each do |page|
      SurveyPage.parse(survey, page)
    end
  end

  def fetch_respondents(survey, credential_hash = { api_key: nil, token: nil })
    unless (api_key = credential_hash[:api_key]) && (token = credential_hash[:token])
      puts "Please provide a hash with api_key and token to fetch survey respondents."
      return
    end

    request = typh_request('get_respondent_list', api_key, token, {survey_id: survey.sm_survey_id.to_s}.to_json).tap { |x| x.run }
    respondents = JSON.parse(request.response.body)['data']['respondents']
    respondents.each do |respondent|
      SurveyRespondentDetail.parse(survey, respondent)
    end

    fetch_responses(survey.reload, credential_hash)
  end

  def fetch_responses(survey, credential_hash = { api_key: nil, token: nil })
    unless (api_key = credential_hash[:api_key]) && (token = credential_hash[:token])
      puts "Please provide a hash with api_key and token to fetch survey responses."
      return
    end

    # to start, we will only pull down completed surveys, and not re-pull these surveys
    # if a respondent is complete and has no response, then we need to pull it down
    # if a respodnent is complete and has a response, then we will not re-pull, it's done

    respondents = SurveyRespondentDetail.where(survey_id: survey.id,
                                               status: "completed")

    respondents_to_pull = respondents.select { |r| r.survey_responses.empty? }

    fetch_response_answers(survey, respondents_to_pull, credential_hash)
  end

  def fetch_response_answers(survey, respondents, credential_hash = { api_key: nil, token: nil })
    unless (api_key = credential_hash[:api_key]) && (token = credential_hash[:token])
      puts "Please provide a hash with api_key and token to fetch survey response answers."
      return
    end

    while (respondents.size > 0)
      ids = respondents.slice!(0, 100).map { |x| x.sm_respondent_id.to_s }
      request = typh_request('get_responses', api_key, token,
                                              { survey_id: survey.sm_survey_id.to_s,
                                                respondent_ids: ids }.to_json).tap { |x| x.run }
      response = JSON.parse(request.response.body)['data']

      response.each do |r|
        begin
          SurveyResponse.parse(survey, r) unless r.nil?
        rescue Exception => e
          raise "Error processing Survey Response for survey #{ survey.inspect }\n\nResponse hash: #{ response.inspect }\n\nAttempting to parse: #{ r.inspect }\n\nException: #{ e.inspect }"
        end
      end
    end
  end

  private
  def typh_request(fragment, api_key, token, body = '{ }')
    # survey monkey's API limits are obnoxious, this is hacky but an easy way
    # to ensure that we're always under the 2 QPS limit
    sleep 0.5 unless ENV["RAILS_ENV"] == 'test'

    Typhoeus::Request.new(
      "https://api.surveymonkey.net/v2/surveys/#{fragment}",
      method: :post,
      params: { api_key: api_key },
      body: body,
      headers: { Authorization: "bearer #{token}", :"Content-Type" => "application/json" }
    )
  end
end
