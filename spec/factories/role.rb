# frozen_string_literal: true

Factory.define(:role) do |f|
  f.association(:user)
  f.name { 'user' }
end

Factory.define(admin_role: :role) do |f|
  f.name { 'admin' }
end
