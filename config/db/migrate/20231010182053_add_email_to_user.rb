# frozen_string_literal: true

ROM::SQL.migration do
  up do
    add_column :users, :email, String
  end

  down do
    drop_column :users, :email
  end
end
