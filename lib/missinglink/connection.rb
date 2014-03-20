require 'typhoeus'

module Missinglink
  module Connection
    extend self

    def request(request_type, body = { })
      (puts "Please provide credentials before making a request." && return) unless credentials_provided?

      JSON.parse(typh_request(request_type,
                              @credential_hash[:api_key],
                              @credential_hash[:token],
                              body.to_json).tap {|x| x.run}.response.body)['data']
    end

    def credential_hash=(key_pair)
      @credential_hash = { api_key: nil, token: nil }.merge(key_pair)
    end

    def credentials_provided?
      !!(@credential_hash && @credential_hash[:api_key] && @credential_hash[:token])
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
