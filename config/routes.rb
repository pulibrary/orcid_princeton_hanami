# frozen_string_literal: true

module OrcidPrinceton
  # Add your routes here. See https://guides.hanamirb.org/routing/overview/ for details.
  class Routes < Hanami::Routes
    root to: 'home.show'
    get '/health', to: 'health.status', as: :health
    get '/health.json', to: 'health.status'
    get '/auth/cas/callback', to: 'session.create', as: :auth_callback
    post '/auth/cas/callback', to: 'session.create'
    get '/admin/orcid_report', to: 'admin.orcid_report', as: :admin_report
    get '/auth/orcid/callback', to: 'orcid.create', as: :orcid_callback
    get '/orcid/failure', to: 'orcid.failure'
    get '/users/:id', to: 'user.show', as: :user
    get '/users/:id.json', to: 'user.show', as: :user_json
    get '/users/:id/validate_tokens', to: 'user.validate_tokens', as: :validate_tokens
    get "/session/destroy", to: "session.destroy", as: :logout
  end
end
