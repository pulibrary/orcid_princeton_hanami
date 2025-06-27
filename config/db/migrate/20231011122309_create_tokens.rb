# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :tokens do
      primary_key :id

      column(:token_type, String, null: false)
      column(:token, String, null: false)
      column(:orcid, String)
      column(:expiration, :timestamp, null: false)
      column(:scope, String)
      column(:user_id, Integer)
      column(:created_at, :timestamp, null: false)
      column(:updated_at, :timestamp, null: false)
    end
  end
end
