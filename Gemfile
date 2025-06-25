# frozen_string_literal: true

source 'https://rubygems.org'

gem 'hanami', '~> 2.2'
gem 'hanami-assets', '~> 2.2'
gem 'hanami-controller', '~> 2.2'
gem 'hanami-db', '~> 2.2'
gem 'hanami-router', '~> 2.2'
gem 'hanami-validations', '~> 2.2'
gem 'hanami-view', '~> 2.2'

gem 'csv'
gem 'dry-operation'
gem 'dry-types', '~> 1.7'
gem 'net-http'
gem 'pg'
gem 'puma'
gem 'rake'

group :development do
  gem 'hanami-webconsole', '~> 2.2'
end

group :development, :test do
  gem 'byebug'
  gem 'coveralls_reborn', require: false
  gem 'dotenv'
  gem 'rubocop'
end

group :cli, :development do
  gem 'hanami-reloader', '~> 2.2'
end

group :cli, :development, :test do
  gem 'hanami-rspec', '~> 2.2'
end

group :test do
  # Database
  gem 'database_cleaner-sequel'

  # Web integration
  gem "axe-core-rspec"
  gem 'capybara'
  gem 'rack-test'
  gem 'rom-factory'
  gem 'selenium-webdriver'
end
