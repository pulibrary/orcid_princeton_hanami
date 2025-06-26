# frozen_string_literal: true

require 'rom/factory'

RSpec.configure do |_config|
  # rubocop:disable Lint/ConstantDefinitionInBlock
  Factory = ROM::Factory.configure do |config|
    config.rom = Hanami.app['db.rom']
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  Dir["#{File.dirname(__FILE__)}/support/factories/*.rb"].each { |file| require file }
end
