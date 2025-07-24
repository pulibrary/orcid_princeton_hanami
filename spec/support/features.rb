# frozen_string_literal: true

require 'capybara/rspec'

Capybara.javascript_driver = if ENV['RUN_IN_BROWSER']
                               :selenium
                             else
                               :selenium_headless
                             end
Capybara.app = Hanami.app
