# frozen_string_literal: true

require 'net/http'

module OrcidPrinceton
  module Operations
    # Checks the API status on https://api.orcid.org/v3.0/apiStatus and returns a Success if the response is all up
    #  returns Falure if any status is false
    class OrcidAPIStatus < OrcidPrinceton::Operation
      def call
        step check
      end

      private

      def check
        response = orcid_api_status
        if response.code == '200'
          process200(response.body)
        else
          Failure("The ORCID API returned HTTP error code: #{response.code}")
        end
      end

      def process200(body)
        json = JSON.parse(body)
        if json.values.include?(false)
          Failure('The ORCID API has an invalid status https://api.orcid.org/v3.0/apiStatus')
        else
          Success(json)
        end
      end

      def orcid_api_status
        uri = URI('https://api.orcid.org/v3.0/apiStatus')
        http = ::Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 2 # seconds
        response = http.get(uri.request_uri)

        # allow one retry to let the us or the api recover from small glitches
        unless response.is_a? ::Net::HTTPSuccess
          sleep(0.5)
          response = http.get(uri.request_uri)
        end
        response
      end
    end
  end
end
