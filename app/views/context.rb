# frozen_string_literal: true

module OrcidPrinceton
  module Views
    # context to expose methods to the templates
    class Context < Hanami::View::Context
      attr_reader :settings
    end
  end
end
