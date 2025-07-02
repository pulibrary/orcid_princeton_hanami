# frozen_string_literal: true

module OrcidPrinceton
  module Actions
    module Session
      # action called after omniauth-cas validates the token in Rack Middleware
      class Create < OrcidPrinceton::Action
        include Deps['repos.user_repo']

        def handle(request, response)
          auth_hash = request.env['omniauth.auth']
          user = user_repo.from_cas(auth_hash)

          if user.nil?
            handle_error(response)
          else
            handle_user(user, request, response)
          end
        end

        private

        def handle_error(response)
          response.flash[:notice] = 'You are not authorized'
          response.redirect_to routes.path(:health) # TODO: this should really be the home page
        end

        def handle_user(user, request, response)
          response.env['warden'].set_user user.uid
          requested_path = request.session[:login_redirect_url]
          response.flash[:notice] = 'You were successfully authenticated'
          response.redirect_to requested_path || routes.path(:health) # TODO: this should really be the home page
        end
      end
    end
  end
end
