# frozen_string_literal: true

require 'hanami'
require 'omniauth-cas'
require 'omniauth-orcid'
require 'warden'

module OrcidPrinceton
  # application configuration for each environment
  class App < Hanami::App
    config.actions.sessions = :cookie, {
      key: 'bookshelf.session',
      secret: settings.session_secret,
      expire_after: 60 * 60 * 24 * 365
    }

    config.middleware.use Warden::Manager
    config.middleware.use OmniAuth::Builder do
      provider :cas, host: Hanami.app.settings.cas_host, url: Hanami.app.settings.cas_url

      provider :orcid, Hanami.app.settings.orcid_client_id, Hanami.app.settings.orcid_client_secret,
               member: true, sandbox: Hanami.app.settings.orcid_sandbox,
               callback_path: Hanami.app.router.path(:orcid_callback)

      # Devise and this configuration are competing for error handling
      #  This set of code stores off the original devise proc and calls that
      #  unless the error is an OmniAuth::Strategies::ORCID failure (the one being configured here)
      @original_omniauth_failure = OmniAuth.config.on_failure
      OmniAuth.config.on_failure = proc do |env|
        if env['omniauth.strategy'].instance_of?(OmniAuth::Strategies::ORCID)
          OrcidPrinceton::Actions::Orcid::Failure.new.call(env)
        else
          @original_omniauth_failure.call(env)
        end
      end
      # OmniAuth.config.full_host = "https://orcid-staging.princeton.edu"
      OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(allow_if: ->(_env) { true })
      OmniAuth.config.allowed_request_methods = %i[get post]
    end

    # need to allow eval for LUX to do it's magic
    config.actions.content_security_policy[:script_src] += " 'unsafe-eval'"

    # needed to allow for inline calls to plausible
    config.actions.content_security_policy[:script_src] += " 'unsafe-inline'"

    # needed to allow for bootstrap javascript include
    config.actions.content_security_policy[:script_src] += ' https://cdn.jsdelivr.net'

    environment(:test) do
    end

    environment(:development) do
      config.base_url = 'http://localhost:3000'
    end

    environment(:staging) do
      config.base_url = 'https://orcid-staging.princeton.edu'
    end

    environment(:production) do
      config.base_url = 'https://orcid-prod.princeton.edu'
    end
  end
end
