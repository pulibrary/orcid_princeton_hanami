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
    before :code_version

    def current_user(request, response)
      if warden_session(request)
        response[:current_user] = user_repo.find_by_uid(warden_session(request).user)
      end
    end

    def code_version(_request, response)
      response[:code_version] = OrcidPrinceton::Service::VersionFooter.info
    end

    def require_authentication(request, response)
      unless warden_session(request)&.user
        response.redirect_to '/auth/cas'
      end
    end

    def require_admin(_request, response)
      unless response[:current_user]&.admin?
        response.flash[:notice] = 'You are not authorized'
        response.redirect_to routes.path(:root)
      end
    end

    def warden_session(request) = request.env['warden']
  end
end
