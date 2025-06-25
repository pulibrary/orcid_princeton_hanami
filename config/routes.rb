# frozen_string_literal: true

module OrcidPrinceton
  # Add your routes here. See https://guides.hanamirb.org/routing/overview/ for details.
  class Routes < Hanami::Routes
    get '/health', to: 'health.status'
  end
end
