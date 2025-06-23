# auto_register: false
# frozen_string_literal: true

require 'hanami/action'
require 'dry/monads'

module OrcidPrinceton
  # Base Hanami action for the ORCID application any top level item (maybe login??) should be done here
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]
  end
end
