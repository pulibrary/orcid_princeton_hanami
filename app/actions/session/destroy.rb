# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Session
      class Destroy < OrcidPrinceton::Action
        def handle(request, response)
          if request.env['warden']&.user
            request.env['warden'].logout(:default)
            response[:current_user] = nil
          end
          response.redirect_to routes.path(:root)
        end
      end
    end
  end
end
