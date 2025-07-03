# auto_register: false
# frozen_string_literal: true

require 'hanami/action'
require 'dry/monads'

module OrcidPrinceton
  # Base Hanami action for the ORCID application any top level item (maybe login??) should be done here
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]

    before :authenticated?
    before :current_user

    def authenticated?(_request, response)
      response.session[:authenticated] = (response.env['warden']&.authenticated? || false)
    end

    def current_user(request, response)
      response.session[:current_user] = request.env['warden']&.user
    end
  end
end
