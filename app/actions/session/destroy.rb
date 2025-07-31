# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Session
      # This logs the current user out
      class Destroy < OrcidPrinceton::Action
        def handle(request, response)
          if warden_session(request)&.user
            warden_session(request).logout(:default)
            response[:current_user] = nil
          end
          response.redirect_to routes.path(:root)
        end
      end
    end
  end
end
