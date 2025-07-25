# frozen_string_literal: true

require 'honeybadger'

module OrcidPrinceton
  module Actions
    module Orcid
      # Callback action for when the ORCID fails to be created
      class Failure < OrcidPrinceton::Action
        def handle(request, response)
          message = request.env['omniauth.error'].detailed_message
          response.flash[:notice] = "Omniauth linking failed #{message}.  Consider linking your account"
          current_user = response[:current_user]
          honeybadger_context = {
            name: current_user.display_name,
            current_user: current_user.id
          }
          Honeybadger.notify(message, context: honeybadger_context)
          response.redirect_to routes.path(:user, id: current_user.id)
        end
      end
    end
  end
end
