# frozen_string_literal: true

# Configuration only — call SimpleCov.start from the test helper (Coveralls.wear! does this).
# See https://github.com/simplecov-ruby/simplecov/issues/581
SimpleCov.configure do
  skip 'spec/'
  skip 'app.rb'
  skip 'config/settings.rb'
end
