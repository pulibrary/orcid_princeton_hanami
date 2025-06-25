require 'rom/factory'

RSpec.configure do |config|
    Factory = ROM::Factory.configure do |config|
        config.rom = Hanami.app["db.rom"]
    end
  
    Dir[File.dirname(__FILE__) + '/support/factories/*.rb'].each { |file| require file }
end
  