# frozen_string_literal: true

module OrcidPrinceton
  module Structs
    # Class for encapsulating Token business logic
    class Token < OrcidPrinceton::DB::Struct
      # def token
      #   if self.attributes[:token].nil?  || self.attributes[:token].blank?
      #     self.attributes[:token] = OrcidPrinceton::Service::EncryptionHelper.new.decrypt(openssl_token)
      #   end
      #   self.attributes[:token]
      # end

      # Check if the token has expired.
      # @return [Boolean] true if the token has expired, false otherwise.
      def expired?
        expiration < Time.now.utc
      end
    end
  end
end
