# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Orcid
      # Callback action for creating ORCID token records in the system
      class Create < OrcidPrinceton::Action
        include Deps['repos.user_repo']
        include Deps['repos.token_repo']

        before :require_authentication # make sure there is a user logged in before serving the report

        def handle(request, response)
          omniauth = request.env['omniauth.auth']
          current_user = response[:current_user]
          user_attributes = current_user.attributes
          user_attributes[:orcid] = omniauth.uid
          current_user = user_repo.update(current_user.id, user_attributes)
          token_repo.create_from_omniauth(omniauth.credentials, current_user)
          # response.redirect_to routes.path(:user, current_user)
          response.redirect_to routes.path(:root)
        end
      end
    end
  end
end
