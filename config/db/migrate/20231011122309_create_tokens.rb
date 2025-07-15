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
      foreign_key :user_id, :users, on_delete: :cascade, null: false
      column(:created_at, :timestamp, null: false)
      column(:updated_at, :timestamp, null: false)
    end
  end
end
