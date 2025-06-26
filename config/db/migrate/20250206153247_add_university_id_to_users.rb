# frozen_string_literal: true

ROM::SQL.migration do
  up do
    add_column :users, :university_id, String
  end

  down do
    drop_column :users, :university_id
  end
end
