# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :roles do
      primary_key :id
      column(:name, String, null: false, index: true)
      column(:resource_id, Integer)
      column(:resource_type, Integer)
      column(:created_at, :timestamp, null: false)
      column(:updated_at, :timestamp, null: false)
      index %i[name resource_type resource_id]
    end
    create_table :users_roles do
      foreign_key :user_id, :users, on_delete: :cascade, null: false
      foreign_key :role_id, :roles, on_delete: :cascade, null: false
      index %i[user_id role_id]
    end
  end
end
