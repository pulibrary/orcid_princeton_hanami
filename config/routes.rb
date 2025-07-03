# frozen_string_literal: true

module OrcidPrinceton
  # Add your routes here. See https://guides.hanamirb.org/routing/overview/ for details.
  class Routes < Hanami::Routes
    get '/health', to: 'health.status', as: :health
    get '/health.json', to: 'health.status'
    get '/session/new', to: 'session.new', as: 'user_login'
    get '/auth/:provider/callback', to: 'session.create', as: :auth_callback
    post '/auth/:provider/callback', to: 'session.create'
  end
end
