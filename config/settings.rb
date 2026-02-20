# frozen_string_literal: true

module OrcidPrinceton
  # application settings
  class Settings < Hanami::Settings
    # Define your app settings here, for example:
    #
    # setting :my_flag, default: false, constructor: Types::Params::Bool

    # Do not worry about the database url for the server:stop rake tasks
    if Object.const_defined?('Rake') && Rake.application.top_level_tasks.include?('servers:stop')
      ENV['DATABASE_URL'] = 'do_not_care'
    # Get the database url from lando if it is not set
    elsif ENV['DATABASE_URL'].nil?
      ENV['DATABASE_URL'] =
        begin
          database_service = JSON.parse(`lando info --format json`, symbolize_names: true).select do |service|
            service[:service] == 'database'
          end.first
          connection = database_service[:external_connection]
          credentials = database_service[:creds]
          port = connection[:port].to_i
          database_url = "#{database_service[:type]}://" \
                        "#{credentials[:user]}@#{connection[:host]}:#{port}/" \
                        "#{Hanami.env}_db"

        # we did not get the correct information from lando
        rescue JSON::ParserError, NoMethodError
          # if we are starting the servers run lando and retry
          if Object.const_defined?('Rake') && Rake.application.top_level_tasks.include?('servers:start')
            system('lando start') # lando was not already started, so we will start it now
            sleep(2)
            retry
          # otherwise just error and tell the user they need to start the servers
          else
            raise "Lando should be running for development.  Start with 'rake servers:start'"
          end
        end
    end

    setting :database_url, default: database_url, constructor: Types::String
    setting :session_secret, default: '__local_development_secret_only__', constructor: Types::String
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
    setting :peoplesoft_output_location, default: '/mnt/peoplesoft/sr_orcid/prod/ORCID_portal_report.csv',
                                         constructor: Types::String

    setting :admin_netids,
            default: %w[abartelm bs3097 cac9 cl4928 hc8719 jh6441 jrg5 kl37 neggink rl3667], constructor: Types::Array
  end
end
