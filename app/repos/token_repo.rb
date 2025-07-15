# frozen_string_literal: true

module OrcidPrinceton
  module Repos
    # class for setting timestamps on tokens and encrypting the token before inserting the data into the database
    class TokenRepo < OrcidPrinceton::DB::Repo
      include Deps['service.encryption_helper']

      def create(attributes)
        attributes[:created_at] = Time.now
        attributes[:updated_at] = Time.now
        attributes[:openssl_token] = encryption_helper(attributes.delete(:token))
        tokens.changeset(:create, attributes).commit
      end

      def update(attributes)
        attributes[:updated_at] = Time.now
        if attributes.key?(:token)
          attributes[:openssl_token] = encryption_helper(attributes.delete(:token))
        end
        tokens.changeset(:create, attributes).commit
      end
    end
  end
end
