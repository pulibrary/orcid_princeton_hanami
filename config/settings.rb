# frozen_string_literal: true

module OrcidPrinceton
  # application settings
  class Settings < Hanami::Settings
    # Define your app settings here, for example:
    #
    # setting :my_flag, default: false, constructor: Types::Params::Bool

    unless ENV['DATABASE_URL']
      database_service = JSON.parse(`lando info --format json`, symbolize_names: true).select do |service|
        service[:service] == 'database'
      end.first
      connection = database_service[:external_connection]
      credentials = database_service[:creds]
      database_url = "#{database_service[:type]}://" \
                    "#{credentials[:user]}@#{connection[:host]}:#{connection[:port]}/" \
                    "#{Hanami.env}_db"
      ENV['DATABASE_URL'] = database_url
    end

    ENV['SESSION_SECRET'] = '__local_development_secret_only__' unless ENV['SESSION_SECRET']

    setting :database_url, default: database_url, constructor: Types::String
    setting :session_secret, constructor: Types::String
    setting :cas_url, constructor: Types::String
    setting :cas_host, constructor: Types::String
    setting :original_omniauth_failure, default: '', constructor: Types::String
    setting :banner_title, default: '', constructor: Types::String
    setting :banner_body, default: '', constructor: Types::String
    setting :orcid_client_id, default: '', constructor: Types::String
    setting :orcid_client_secret, default: '', constructor: Types::String
    setting :orcid_sandbox, default: false, constructor: Types::Params::Bool
    setting :orcid_url, default: 'https://api.orcid.org/v3.0', constructor: Types::String
    setting :openssl_key, default: '', constructor: Types::String
    setting :openssl_algorithm, default: '', constructor: Types::String
    setting :openssl_iv_len, default: 16, constructor: Types::Params::Integer
  end
end
