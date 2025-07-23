# frozen_string_literal: true

source 'https://rubygems.org'

gem 'hanami', '~> 2.2'
gem 'hanami-assets', '~> 2.2'
gem 'hanami-controller', '~> 2.2'
gem 'hanami-db', '~> 2.2'
gem 'hanami-router', '~> 2.2'
gem 'hanami-validations', '~> 2.2'
gem 'hanami-view', '~> 2.2'

gem 'bcrypt_pbkdf'
gem 'csv'
gem 'dry-monads', '~> 1.9'
gem 'dry-operation'
gem 'dry-types', '~> 1.7'
gem 'ed25519'
gem 'honeybadger'
# TODO: why two different http gems?
gem 'httparty'
gem 'net-http'
gem 'omniauth-cas'
gem 'omniauth-orcid'
gem 'pg'
gem 'puma'
gem 'rake'
gem 'tilt', '~> 2.0'
gem 'tilt-jbuilder'
gem 'warden'
gem 'whenever'

group :development do
  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'hanami-webconsole', '~> 2.2'
end

group :development, :test do
  gem 'byebug'
  gem 'coveralls_reborn', require: false
  gem 'dotenv'
  gem 'ffaker'
  gem 'rubocop'
  gem 'webmock'
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
  gem 'axe-core-rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'rom-factory'
  gem 'selenium-webdriver'
end
