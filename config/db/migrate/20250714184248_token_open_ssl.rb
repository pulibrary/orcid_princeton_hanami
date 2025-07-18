# frozen_string_literal: true

ROM::SQL.migration do
  up do
    add_column :tokens, :openssl_token, Text
  end

  down do
    drop_column :tokens, :openssl_token
  end
end
