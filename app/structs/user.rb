# frozen_string_literal: true

module OrcidPrinceton
  module Structs
    # Class for encapsulating User business logic
    class User < OrcidPrinceton::DB::Struct
      def admin?
        @admin ||= roles.any? { |role| role.name == 'admin' }
        @admin
      end

      # Are all of this user's tokens expired?
      # returns true or false
      def tokens_expired?
        tokens.all?(&:expired?)
      end

      def valid_token
        return nil if tokens_expired?

        valid_tokens = tokens.reject(&:expired?)
        valid_tokens.first
      end
    end
  end
end
