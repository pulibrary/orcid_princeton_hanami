# frozen_string_literal: true

require 'cgi'

module OrcidPrinceton
  module Actions
    module Session
      # called when a user clicks the login link to forward to CAS
      class New < OrcidPrinceton::Action
        def handle(request, response)
          response.session[:login_redirect_url] = request.referrer
          response.redirect_to cas_url(request)
        end

        private

        # rubocop:disable Metrics/AbcSize
        def cas_url(request)
          OmniAuth.strategies.first.configure(host: Hanami.app.settings.cas_host, url: Hanami.app.settings.cas_url)
          omniauth_strategy = OmniAuth.strategies.first.new(Hanami.app)
          service_url = omniauth_strategy.append_params(routes.url(:auth_callback, provider: 'cas'),
                                                        { url: request.referer })
          omniauth_strategy.login_url(service_url)
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
