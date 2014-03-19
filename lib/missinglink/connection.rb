require 'typhoeus'

module Missinglink
  module Connection
    extend self

    def request(request_type, key, token, body = { })
      JSON.parse(typh_request(request_type, api_key, token, body.to_json).tap {|x| x.run}.response.body)['data']
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
end
