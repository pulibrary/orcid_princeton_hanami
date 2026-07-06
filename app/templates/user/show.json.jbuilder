# frozen_string_literal: true

json.extract! user, :id, :uid, :provider, :orcid, :given_name, :family_name, :display_name, :created_at, :updated_at
json.url Hanami.app.router.url(:user_json, id: user.id)
