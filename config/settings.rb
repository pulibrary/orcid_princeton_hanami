# frozen_string_literal: true

require 'json'

module OrcidPrinceton
  # application settings
  # DB URL resolution priority:
  # 1) Respect DATABASE_URL if already set (Devbox/CI/explicit user config)
  # 2) If lando is available, use lando db (existing behavior)
  # 3) If lando is NOT available, default to local devbox postgres socket
  class Settings < Hanami::Settings
    def self.lando_available?(cmd)
      system("#{cmd} --version > /dev/null 2>&1")
    end

    def self.rake_task?(task_name)
      Object.const_defined?('Rake') && Rake.application.top_level_tasks.include?(task_name)
    end

    def self.devbox_socket_url(root, env)
      host_dir = File.join(root, '.postgres')
      dbname = (env.to_s == 'test' ? 'orcid_princeton_hanami_test' : 'orcid_princeton_hanami_development')
      "postgres://#{ENV.fetch('USER', 'postgres')}@/#{dbname}?host=#{host_dir}&port=5432"
    end

    def self.lando_database_url(cmd, hanami_env)
      services = JSON.parse(`#{cmd} info --format json`, symbolize_names: true)
      database_service = services.find { |svc| svc[:service] == 'database' }
      raise NoMethodError unless database_service

      connection = database_service[:external_connection]
      creds = database_service[:creds]
      "#{database_service[:type]}://#{creds[:user]}@#{connection[:host]}:#{connection[:port]}/#{hanami_env}_db"
    end

    root = Dir.pwd
    env_name = Hanami.env.to_s
    lando_cmd = ENV.fetch('LANDO', 'lando')

    database_url = rake_task?('servers:stop') ? 'do_not_care' : ENV.fetch('DATABASE_URL', nil)

    if database_url.to_s.strip.empty?
      if lando_available?(lando_cmd)
        begin
          database_url = lando_database_url(lando_cmd, env_name)
        rescue JSON::ParserError, NoMethodError
          if rake_task?('servers:start')
            system("#{lando_cmd} start")
            sleep(2)
            retry
          end
          database_url = devbox_socket_url(root, env_name)
        end
      else
        database_url = devbox_socket_url(root, env_name)
      end
    end

    ENV['DATABASE_URL'] = database_url

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
    setting :peoplesoft_output_location,
            default: '/mnt/peoplesoft/sr_orcid/prod/ORCID_portal_report.csv',
            constructor: Types::String
  end
end
