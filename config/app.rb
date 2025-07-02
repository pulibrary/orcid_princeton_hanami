# frozen_string_literal: true

require 'hanami'
require 'omniauth-cas'
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
    end

    environment(:test) do
    end

    environment(:development) do
      config.base_url = 'http://localhost:2300'
    end

    environment(:staging) do
    end

    environment(:production) do
    end
  end
end
