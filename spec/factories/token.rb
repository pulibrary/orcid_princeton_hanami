# frozen_string_literal: true

Factory.define(:token) do |f|
  f.token { 'e82938fa-a287-42cf-a2ce-f48ef68c9a35' }
  f.expiration { Time.zone.at(2_329_902_061) }
  f.association(:user)
end

Factory.define(:expired_token) do |f|
  f.expiration { Time.zone.at(1_698_165_083) }
end
