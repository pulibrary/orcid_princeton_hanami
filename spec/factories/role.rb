# frozen_string_literal: true

Factory.define(:role) do |f|
  f.association(:users)
  f.name { 'user' }
  f.timestamps
  f.trait :admin do |t|
    t.name 'admin'
  end
end
