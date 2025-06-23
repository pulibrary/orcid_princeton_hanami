# frozen_string_literal: true
require 'byebug'

module OrcidPrinceton
  class Settings < Hanami::Settings
    # Define your app settings here, for example:
    #
    # setting :my_flag, default: false, constructor: Types::Params::Bool

    lando_info = `lando info --format json`
    if lando_info
      database_service = JSON.parse(`lando info --format json`, symbolize_names: true).select{|service| service[:service] == "database" }.first
      connection = database_service[:external_connection]
      credentials = database_service[:creds]
      database_url = "#{database_service[:type]}://#{credentials[:user]}@#{connection[:host]}:#{connection[:port]}/#{Hanami.env}_db"
      ENV["DATABASE_URL"] = database_url
    else
      database_url = ENV["DATABASE_URL"]
    end

    setting :database_url, default: database_url, constructor: Types::String
  end
end
