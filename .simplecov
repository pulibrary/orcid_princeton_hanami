# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter 'spec/'
  add_filter 'app.rb'
  add_filter 'config/settings.rb'
end
