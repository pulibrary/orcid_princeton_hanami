# frozen_string_literal: true

require 'honeybadger'

module OrcidPrinceton
  module Actions
    module Session
      # action called after omniauth-entra-id validates the token in Rack Middleware
      class CreateEntra < OrcidPrinceton::Action
        include Deps['repos.user_repo']

        def handle(request, response)
          auth_hash = request.env['omniauth.auth']
          if auth_hash.nil?
            notify_missing_hash(response)
          else
            authenticate_entra_user(auth_hash, request, response)
          end
        end

        private

        def notify_missing_hash(response)
          Honeybadger.notify('Entra ID login failed: OmniAuth auth hash is missing')
          handle_error(response)
        end

        def authenticate_entra_user(auth_hash, request, response)
          user = user_repo.from_entra_id(auth_hash)
          if user.nil?
            handle_error(response)
          else
            handle_user(user, request, response)
          end
        rescue StandardError => e
          notify_entra_exception(e, auth_hash)
          handle_error(response)
        end

        def notify_entra_exception(exception, auth_hash)
          auth_hash_h = begin
            auth_hash.to_h
          rescue StandardError
            nil
          end
          Honeybadger.notify(exception, context: { auth_hash: auth_hash_h })
        end

        def handle_error(response)
          response.flash[:notice] = 'You are not authorized'
          response.redirect_to routes.path(:root)
        end

        def handle_user(user, request, response)
          warden_session(request).set_user user.uid
          requested_path = request.session[:login_redirect_url]
          response.flash[:notice] = 'You were successfully authenticated'
          response.redirect_to requested_path || routes.path(:root)
        end
      end
    end
  end
end
