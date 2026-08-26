# frozen_string_literal: true

require 'rom/factory'

RSpec.configure do |_config|
  # rubocop:disable-next Lint/ConstantDefinitionInBlock
  Factory = ROM::Factory.configure do |config|
    config.rom = Hanami.app['db.rom']
  end

  SPEC_ROOT.glob('factories/**/*.rb').each { |file| require file }
end
