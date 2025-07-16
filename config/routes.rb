# frozen_string_literal: true

module OrcidPrinceton
  # Add your routes here. See https://guides.hanamirb.org/routing/overview/ for details.
  class Routes < Hanami::Routes
    root to: 'home.show'
    get '/health', to: 'health.status', as: :health
    get '/health.json', to: 'health.status'
    get '/session/new', to: 'session.new', as: 'user_login'
    get '/auth/:provider/callback', to: 'session.create', as: :auth_callback
    post '/auth/:provider/callback', to: 'session.create'
    get '/admin/orcid_report', to: 'admin.orcid_report', as: :admin_report
  end
end
