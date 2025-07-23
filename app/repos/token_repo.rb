# frozen_string_literal: true

module OrcidPrinceton
  module Repos
    # class for setting timestamps on tokens and encrypting the token before inserting the data into the database
    class TokenRepo < OrcidPrinceton::DB::Repo
      def get(id)
        token = tokens.by_pk(id).one!
        decrypt_openssl_token(token)
      end

      def last = decrypt_openssl_token(tokens.last)

      def create(attributes)
        attributes[:created_at] = Time.now
        attributes[:updated_at] = Time.now
        tokens.changeset(:create, encrypt_openssl_token(attributes)).commit
      end

      def update(id, attributes)
        attributes[:updated_at] = Time.now
        tokens.by_pk(id).changeset(:update, encrypt_openssl_token(attributes)).commit
        get(id)
      end

      def expire_now(id)
        tokens.by_pk(id).changeset(:update, { expiration: Time.now }).commit
      end

      # Create a token from an omniauth hash.
      # @param credentials [OmniAuth::AuthHash] The credentials hash from the omniauth response.
      # @param user [User] The user to associate the token with.
      # @return [Token] The token that was created.
      def create_from_omniauth(credentials, user)
        create(
          token: credentials.token,
          expiration: Time.at(credentials.expires_at),
          user_id: user.id,
          token_type: 'ORC',
          orcid: user.orcid
          # TODO: ADD REFRESH TOKEN
          # refresh_token: credentials.refresh_token
        )
      end

      private

      def decrypt_openssl_token(token)
        if token.openssl_token
          token.attributes[:token] = OrcidPrinceton::Service::EncryptionHelper.new.decrypt(token.openssl_token)
        end
        token
      end

      def encrypt_openssl_token(attributes)
        if attributes.key?(:token)
          openssl_token = OrcidPrinceton::Service::EncryptionHelper.new.encrypt(attributes.delete(:token))
          attributes[:openssl_token] = openssl_token
          attributes[:token] = ''
        end
        attributes
      end
    end
  end
end
