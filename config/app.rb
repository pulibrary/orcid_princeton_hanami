# frozen_string_literal: true

require 'hanami'

module OrcidPrinceton
  # application configuration for each environment
  class App < Hanami::App
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
