# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :users do
      primary_key :id

      column(:uid, String, null: false, index: true, unique: true)
      column(:provider, String, null: false, index: true)
      column(:orcid, String)
      column(:given_name, String)
      column(:family_name, String)
      column(:display_name, String)
      column(:created_at, :timestamp, null: false)
      column(:updated_at, :timestamp, null: false)
    end
  end
end
