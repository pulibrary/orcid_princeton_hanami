# frozen_string_literal: true

require 'httparty'

module OrcidPrinceton
  module Operations
    # Operation to validate any user's tokens
    class ValidateUserTokens < OrcidPrinceton::Operation
      include Deps['repos.user_repo', 'repos.token_repo']

      def call(user_id)
        user = step load_user(user_id)
        step validate_tokens(user)
      end

      private

      def load_user(user_id)
        user = user_repo.get(user_id)
        Success(user)
      rescue ROM::TupleCountMismatchError
        Failure('The user does not exists')
      end

      def validate_tokens(user)
        Time.now
        user.valid_tokens.each do |token|
          if valid_in_orcid?(token.token, user.orcid) == false
            token_repo.expire_now(token.id)
          end
        end
        Success(user)
      rescue RuntimeError => e
        Failure("Error validating tokens #{e}")
      end

      # Checks is a token is still valid with ORCiD
      # A token can become invalid if the user revokes it within ORCiD
      def valid_in_orcid?(token, orcid)
        url = "#{Hanami.app.settings.orcid_url}/#{orcid}/record"
        headers = {
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{token}"
        }
        response = HTTParty.get(url, headers:)

        # Assume it's invalid for all other statuses.
        # We could also look inside response.parsed_response for other errors if need to.
        response.code == 200
      end
    end
  end
end
