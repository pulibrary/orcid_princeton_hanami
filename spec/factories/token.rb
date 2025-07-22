# frozen_string_literal: true

Factory.define(:token) do |f|
  f.token { 'e82938fa-a287-42cf-a2ce-f48ef68c9a35' }
  f.expiration { Time.now + (24 * 60 * 60) } # tomorrow
  f.token_type { 'ORCID' }
  f.association(:user)
  f.timestamps

  f.trait :expired do |t|
    t.expiration { Time.now - (24 * 60 * 60) } # yesterday
  end
end
