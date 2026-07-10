# frozen_string_literal: true

require 'honeybadger'

module OrcidPrinceton
  module Actions
    module Session
      # This action is called when an OmniAuth authentication fails. It logs the failure and notifies Honeybadger,
      #  then redirects the user to the root path.
      class Failure < OrcidPrinceton::Action
        params do
          required(:message).value(:string)
        end
        def handle(request, response)
          Hanami.app['logger'].warn("Authentication failure: #{request.params[:message]}")
          Hanami.app['logger'].warn("request: #{request.inspect}")
          Honeybadger.notify("Authentication failure: #{request.params[:message]}")
          response.redirect_to routes.path(:root)
        end
      end
    end
  end
end
