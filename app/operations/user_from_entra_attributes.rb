# frozen_string_literal: true

require 'net/http'
require 'net/ldap'
require 'honeybadger'

module OrcidPrinceton
  module Operations
    # Converts the cas token into a user
    class UserFromEntraAttributes < UserFromAttributes
      def self.parse_entra_uid(access_token)
        return nil if access_token.nil?

        email = access_token.extra.raw_info.unique_name
        email.split('@princeton.edu').first
      end

      private

      # rubocop:disable Metrics/AbcSize
      def attributes_from_token(access_token)
        uid = self.class.parse_entra_uid(access_token)
        alternate_value = alternate_value(access_token.info.email, uid)
        { university_id: uid,
          email: access_token.extra.raw_info.email, provider: access_token.provider.to_s,
          given_name: access_token.extra.raw_info.given_name || alternate_value,
          family_name: access_token.extra.raw_info.family_name || alternate_value,
          display_name: access_token.extra.raw_info.name || alternate_value }
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
