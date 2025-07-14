# frozen_string_literal: true

module OrcidPrinceton
  module Structs
    # Class for encapsulating User business logic
    class User < OrcidPrinceton::DB::Struct
      def admin?
        @admin ||= roles.any? { |role| role.name == 'admin' }
        @admin
      end
    end
  end
end
