# auto_register: false
# frozen_string_literal: true

module OrcidPrinceton
  module Views
    # Base Hanami view helpers for the ORCID application
    module Helpers
      def login_path
        if Flipflop.entra_id_login?
          '/auth/entra_id'
        else
          "/auth/#{Hanami.app.settings.default_auth_provider}"
        end
      end
    end
  end
end
