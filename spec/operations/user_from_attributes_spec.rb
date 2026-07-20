# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
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
    expect(result).to be_success
    updated_user = user_repo.get(user.id)
    expect(updated_user.university_id).to eq('999999999')
    expect(updated_user.display_name).to eq('Areyou, Who')
    expect(updated_user.given_name).to eq('Who')
    expect(updated_user.family_name).to eq('Areyou')
  end

  it 'Updates the user with cas, and does overwrite existing values', db: true do
    result = described_class.new.call(uid: user.uid, access_token: auth_hash)
    expect(result).to be_success
    updated_user = user_repo.get(user.id)
    expect(updated_user.university_id).to eq('999999999')
    expect(updated_user.display_name).to eq('Areyou, Who')
  end

  it 'creates the user with cas', db: true do
    auth_hash[:uid] = 'other_user'
    result = described_class.new.call(uid: 'other_user', access_token: auth_hash)
    expect(result).to be_success
    new_user = user_repo.find_by_uid('other_user')
    expect(new_user.university_id).to eq('999999999')
    expect(new_user.display_name).to eq('Areyou, Who')
    expect(new_user.given_name).to eq('Who')
    expect(new_user.family_name).to eq('Areyou')
  end

  context 'with LDAP mock/stubbing' do
    let(:ldap_entry) do
      entry = double('ldap_entry')
      allow(entry).to receive(:universityid).and_return('098136217')
      allow(entry).to receive(:[]).with(:uid).and_return(['tigerdatatester'])
      allow(entry).to receive(:[]).with(:universityid).and_return(['098136217'])
      allow(entry).to receive(:[]).with(:mail).and_return(['tigerdatatester@princeton.edu'])
      allow(entry).to receive(:[]).with(:givenname).and_return(['TigerData'])
      allow(entry).to receive(:[]).with(:sn).and_return(['Tester'])
      allow(entry).to receive(:[]).with(:displayname).and_return(['TigerData Tester'])
      entry
    end

    before do
      allow_any_instance_of(described_class).to receive(:ldap_info).with('tigerdatatester').and_return(ldap_entry)
    end

    it 'Updates the user with ldap values when the university id is missing', db: true do
      user = user_repo.create(uid: 'tigerdatatester', provider: 'cas')
      auth_hash.extra.universityid = nil
      auth_hash.extra.displayname = nil
      result = described_class.new.call(uid: user.uid, access_token: auth_hash)
      expect(result).to be_success
      updated_user = user_repo.find_by_uid('tigerdatatester')
      expect(updated_user.university_id).to eq('098136217') # from ldap
      expect(updated_user.display_name).to eq('TigerData Tester') # from ldap
      expect(updated_user.given_name).to eq('Who') # from auth hash
      expect(updated_user.family_name).to eq('Areyou') # from auth hash
    end

    it 'creates a new user with ldap values when they do not exist and university id is missing in token', db: true do
      auth_hash.extra.universityid = nil
      auth_hash.extra.displayname = nil
      result = described_class.new.call(uid: 'tigerdatatester', access_token: auth_hash)
      expect(result).to be_success
      new_user = user_repo.find_by_uid('tigerdatatester')
      expect(new_user).not_to be_nil
      expect(new_user.university_id).to eq('098136217') # from ldap
      expect(new_user.display_name).to eq('TigerData Tester') # from ldap
    end

    context 'when LDAP cannot find the user (ldap_info returns nil)' do
      before do
        allow_any_instance_of(described_class).to receive(:ldap_info).with('tigerdatatester').and_return(nil)
      end

      it 'returns a Failure monad', db: true do
        user = user_repo.create(uid: 'tigerdatatester', provider: 'cas')
        auth_hash.extra.universityid = nil
        result = described_class.new.call(uid: user.uid, access_token: auth_hash)
        expect(result).to be_failure
        expect(result.failure).to eq('Can not find the university id for tigerdatatester')
      end
    end

    context 'when LDAP returns an entry with nil universityid' do
      let(:invalid_ldap_entry) do
        entry = double('invalid_ldap_entry')
        allow(entry).to receive(:universityid).and_return(nil)
        entry
      end

      before do
        # rubocop:disable Layout/LineLength
        allow_any_instance_of(described_class).to receive(:ldap_info).with('tigerdatatester').and_return(invalid_ldap_entry)
        # rubocop:enable Layout/LineLength
      end

      it 'returns a Failure monad', db: true do
        user = user_repo.create(uid: 'tigerdatatester', provider: 'cas')
        auth_hash.extra.universityid = nil
        result = described_class.new.call(uid: user.uid, access_token: auth_hash)
        expect(result).to be_failure
        expect(result.failure).to eq('Can not find the university id for tigerdatatester')
      end
    end
  end

  context 'when user already has given_name set in the database' do
    let(:user) do
      Factory[:user, university_id: '999999999', given_name: 'ExistingGivenName', display_name: 'Existing DisplayName']
    end

    it 'does not overwrite existing database attributes from CAS/token', db: true do
      expect(user.given_name).to eq('ExistingGivenName')
      result = described_class.new.call(uid: user.uid, access_token: auth_hash)
      expect(result).to be_success
      updated_user = user_repo.get(user.id)
      expect(updated_user.given_name).to eq('ExistingGivenName')
      expect(updated_user.display_name).to eq('Existing DisplayName')
    end
  end

  context 'alternate_value fallback behavior in token parsing' do
    context 'when university_id is present' do
      it 'uses the uid as fallback when givenname, sn, or displayname are nil', db: true do
        auth_hash[:uid] = 'some_uid'
        auth_hash.extra.universityid = '999999999'
        auth_hash.extra.givenname = nil
        auth_hash.extra.sn = nil
        auth_hash.extra.displayname = nil

        result = described_class.new.call(uid: 'some_uid', access_token: auth_hash)
        expect(result).to be_success
        new_user = user_repo.find_by_uid('some_uid')
        expect(new_user.given_name).to eq('some_uid')
        expect(new_user.family_name).to eq('some_uid')
        expect(new_user.display_name).to eq('some_uid')
      end
    end

    context 'when university_id is nil' do
      # Since university_id is nil, it will trigger LDAP lookup. Let's mock LDAP.
      let(:ldap_entry) do
        entry = double('ldap_entry')
        allow(entry).to receive(:universityid).and_return('098136217')
        allow(entry).to receive(:[]).with(:uid).and_return(['tigerdatatester'])
        allow(entry).to receive(:[]).with(:universityid).and_return(['098136217'])
        allow(entry).to receive(:[]).with(:mail).and_return(['tigerdatatester@princeton.edu'])
        allow(entry).to receive(:[]).with(:givenname).and_return(['TigerData'])
        allow(entry).to receive(:[]).with(:sn).and_return(['Tester'])
        allow(entry).to receive(:[]).with(:displayname).and_return(['TigerData Tester'])
        entry
      end

      before do
        allow_any_instance_of(described_class).to receive(:ldap_info).with('tigerdatatester').and_return(ldap_entry)
      end

      it 'returns nil for the name attributes so they get populated from LDAP', db: true do
        auth_hash.extra.universityid = nil
        auth_hash.extra.givenname = nil
        auth_hash.extra.sn = nil
        auth_hash.extra.displayname = nil

        result = described_class.new.call(uid: 'tigerdatatester', access_token: auth_hash)
        expect(result).to be_success
        new_user = user_repo.find_by_uid('tigerdatatester')
        expect(new_user.university_id).to eq('098136217')
        expect(new_user.given_name).to eq('TigerData')
        expect(new_user.family_name).to eq('Tester')
        expect(new_user.display_name).to eq('TigerData Tester')
      end
    end
  end

  # this test has been mocked to run both locally and on circle ci
  it 'Updates the user with ldap values when the university id is missing', db: true do
    user = user_repo.create(uid: 'tigerdatatester', provider: 'cas')
    auth_hash.extra.universityid = nil
    auth_hash.extra.displayname = nil

    ldap_attr = double('ldap_entry', universityid: ['098136217'])
    allow(ldap_attr).to receive(:[]) do |key|
      {
        uid: ['tigerdatatester'],
        universityid: ['098136217'],
        mail: ['who@princeton.edu'],
        givenname: ['Who'],
        sn: ['Areyou'],
        displayname: ['TigerData Tester']
      }.fetch(key.to_sym, nil)
    end

    operation = described_class.new
    allow(operation).to receive(:ldap_info).with('tigerdatatester').and_return(ldap_attr)

    result = operation.call(uid: user.uid, access_token: auth_hash)
    expect(result).to be_success
    updated_user = user_repo.find_by_uid('tigerdatatester')
    expect(updated_user.university_id).to eq('098136217') # from ldap
    expect(updated_user.display_name).to eq('TigerData Tester') # from ldap
    expect(updated_user.given_name).to eq('Who') # from auth hash
    expect(updated_user.family_name).to eq('Areyou') # from auth hash
  end
end
# rubocop:enable Metrics/BlockLength
