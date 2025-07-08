# auto_register: false
# frozen_string_literal: true

require 'hanami/view'

module OrcidPrinceton
  # Base Hanami view for the ORCID application
  class View < Hanami::View
    expose :authenticated?, layout: true
    expose :current_user, layout: true
  end
end
