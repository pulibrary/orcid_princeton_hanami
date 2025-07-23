# frozen_string_literal: true

json.extract! user, :id, :uid, :provider, :orcid, :given_name, :family_name, :display_name, :created_at, :updated_at
json.url user_url(user, format: :json)
