# frozen_string_literal: true

require "json"

module OrcidPrinceton
  class Settings < Hanami::Settings
    # DB URL resolution priority:
    # 1) Respect DATABASE_URL if already set (Devbox/CI/explicit user config)
    # 2) If lando is available, use lando db (existing behavior)
    # 3) If lando is NOT available, default to local devbox postgres socket
    #
    # IMPORTANT: always use Hanami conventional DB names:
    #   orcid_princeton_hanami_development / orcid_princeton_hanami_test
    # This avoids drifting between *_dev and *_development.
    #
    # Also keep existing rake servers:start behavior: if lando info fails, auto-start lando then retry.

    def self.lando_available?(cmd)
      system("#{cmd} --version > /dev/null 2>&1")
    end

    def self.devbox_socket_url(root, env)
      host_dir = File.join(root, ".postgres")
      dbname =
        case env.to_s
        when "test" then "orcid_princeton_hanami_test"
        else "orcid_princeton_hanami_development"
        end

      "postgres://#{ENV.fetch("USER", "postgres")}@/#{dbname}?host=#{host_dir}&port=5432"
    end

    def self.lando_database_url(cmd, hanami_env)
      services = JSON.parse(`#{cmd} info --format json`, symbolize_names: true)
      database_service = services.find { |svc| svc[:service] == "database" }
      raise NoMethodError unless database_service

      connection = database_service[:external_connection]
      credentials = database_service[:creds]
      port = connection[:port].to_i

      # preserve existing lando convention in this repo:
      #   development_db / test_db (etc.)
      "#{database_service[:type]}://" \
        "#{credentials[:user]}@#{connection[:host]}:#{port}/" \
        "#{hanami_env}_db"
    end

    root = Dir.pwd
    env_name = Hanami.env.to_s
    lando_cmd = ENV.fetch("LANDO", "lando")

    database_url = ENV["DATABASE_URL"]

    if Object.const_defined?("Rake") && Rake.application.top_level_tasks.include?("servers:stop")
      database_url = "do_not_care"
    end

    if database_url.nil? || database_url.strip.empty?
      if lando_available?(lando_cmd)
        begin
          database_url = lando_database_url(lando_cmd, env_name)
        rescue JSON::ParserError, NoMethodError
          if Object.const_defined?("Rake") && Rake.application.top_level_tasks.include?("servers:start")
            system("#{lando_cmd} start")
            sleep(2)
            retry
          else
            database_url = devbox_socket_url(root, env_name)
          end
        end
      else
        database_url = devbox_socket_url(root, env_name)
      end
    end

    ENV["DATABASE_URL"] = database_url

    setting :database_url, default: database_url, constructor: Types::String
    setting :session_secret, default: "__local_development_secret_only__", constructor: Types::String
    setting :cas_url, constructor: Types::String
    setting :cas_host, constructor: Types::String
    setting :original_omniauth_failure, default: "", constructor: Types::String
    setting :banner_title, default: "", constructor: Types::String
    setting :banner_body, default: "", constructor: Types::String
    setting :orcid_client_id, default: "", constructor: Types::String
    setting :orcid_client_secret, default: "", constructor: Types::String
    setting :orcid_sandbox, default: false, constructor: Types::Params::Bool
    setting :orcid_url, default: "https://api.orcid.org/v3.0", constructor: Types::String
    setting :openssl_key, default: "", constructor: Types::String
    setting :openssl_algorithm, default: "", constructor: Types::String
    setting :openssl_iv_len, default: 16, constructor: Types::Params::Integer
    setting :peoplesoft_output_location,
            default: "/mnt/peoplesoft/sr_orcid/prod/ORCID_portal_report.csv",
            constructor: Types::String
  end
end

