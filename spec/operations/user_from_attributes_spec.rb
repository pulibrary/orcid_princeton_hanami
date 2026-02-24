# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Operations::UserFromAttributes do
  let(:user_repo) { OrcidPrinceton::Repos::UserRepo.new }
  let(:auth_hash) do
    OmniAuth::AuthHash.new(provider: 'cas', uid: user.uid,
                           extra: OmniAuth::AuthHash.new(mail: 'who@princeton.edu', user: user.uid,
                                                         authnContextClass: 'mfa-duo', campusid: 'who.areyou',
                                                         puresidentdepartmentnumber: '41999', uid: user.uid,
                                                         title: 'The Developer, Library - Information Technology.',
                                                         universityid: '999999999', displayname: 'Areyou, Who',
                                                         pudisplayname: 'Areyou, Who',
                                                         edupersonaffiliation: 'staff', givenname: 'Who',
                                                         sn: 'Areyou', department: 'Library - Information Technology',
                                                         edupersonprincipalname: 'who@princeton.edu',
                                                         puresidentdepartment: 'Library - Information Technology',
                                                         puaffiliation: 'stf', departmentnumber: '41999',
                                                         pustatus: 'stf'))
  end
  let(:user) { Factory[:user, university_id: nil, given_name: nil] }

  it 'Updates the user with cas values', db: true do
    user = user_repo.create(uid: 'abc123', provider: 'cas')
    result = described_class.new.call(uid: user.uid, access_token: auth_hash)
    expect(result).to be_a Dry::Monads::Result::Success
    updated_user = user_repo.get(user.id)
    expect(updated_user.university_id).to eq('999999999')
    expect(updated_user.display_name).to eq('Areyou, Who')
    expect(updated_user.given_name).to eq('Who')
    expect(updated_user.family_name).to eq('Areyou')
  end

  it 'Updates the user with cas, and does overwrite existing values', db: true do
    result = described_class.new.call(uid: user.uid, access_token: auth_hash)
    expect(result).to be_a Dry::Monads::Result::Success
    updated_user = user_repo.get(user.id)
    expect(updated_user.university_id).to eq('999999999')
    expect(updated_user.display_name).to eq('Areyou, Who')
  end

  it 'creates the user with cas', db: true do
    auth_hash[:uid] = 'other_user'
    result = described_class.new.call(uid: 'other_user', access_token: auth_hash)
    expect(result).to be_a Dry::Monads::Result::Success
    new_user = user_repo.find_by_uid('other_user')
    expect(new_user.university_id).to eq('999999999')
    expect(new_user.display_name).to eq('Areyou, Who')
    expect(new_user.given_name).to eq('Who')
    expect(new_user.family_name).to eq('Areyou')
  end

  # this test can not be run on circle (tagged :no_ci to not run on circle ci)
  it 'Updates the user with ldap values when the university id is missing', db: true, no_ci: true do
    user = user_repo.create(uid: 'tigerdatatester', provider: 'cas')
    auth_hash.extra.universityid = nil
    auth_hash.extra.displayname = nil
    result = described_class.new.call(uid: user.uid, access_token: auth_hash)
    expect(result).to be_a Dry::Monads::Result::Success
    updated_user = user_repo.find_by_uid('tigerdatatester')
    expect(updated_user.university_id).to eq('098136217') # from ldap
    expect(updated_user.display_name).to eq('TigerData Tester') # from ldap
    expect(updated_user.given_name).to eq('Who') # from auth hash
    expect(updated_user.family_name).to eq('Areyou') # from auth hash
  end
end
