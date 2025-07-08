# auto_register: false
# frozen_string_literal: true

require 'hanami/action'
require 'dry/monads'

module OrcidPrinceton
  # Base Hanami action for the ORCID application any top level item (maybe login??) should be done here
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]

    include Deps['repos.user_repo']

    before :current_user

    def current_user(request, response)
      if request.env['warden']
        response[:current_user] = user_repo.find_by_uid(request.env['warden'].user)
      end
    end
  end
end
