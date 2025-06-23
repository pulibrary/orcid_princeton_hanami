# frozen_string_literal: true

require 'hanami'

module OrcidPrinceton
  # application configuration for each environment
  class App < Hanami::App
    config.actions.sessions = :cookie, {
      key: 'bookshelf.session',
      secret: settings.session_secret,
      expire_after: 60 * 60 * 24 * 365
    }

    environment(:test) do
    end

    environment(:development) do
    end

    environment(:staging) do
    end

    environment(:production) do
    end
  end
end
