# frozen_string_literal: true

require 'warden'

RSpec.configure do |config|
  include Warden::Test::Helpers
  config.after { Warden.test_reset! }
end
