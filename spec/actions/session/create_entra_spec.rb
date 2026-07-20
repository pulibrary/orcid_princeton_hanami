# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Session::CreateEntra do
  let(:university_id) { '999999999' }
  let(:auth_hash) do
    OmniAuth::AuthHash.new(provider: 'entra_id', uid: '<some really large random string>', credentials: nil,
                           info: OmniAuth::AuthHash.new(email: 'who.areyou@princeton.edu', first_name: 'Who',
                                                        last_name: 'Areyou', name: 'Who Areyou',
                                                        nickname: 'test456@princeton.edu'),
                           extra: OmniAuth::AuthHash.new(
                             raw_info: OmniAuth::AuthHash.new(app_displayname: 'orcid-dev',
                                                              email: 'who.areyou@princeton.edu',
                                                              family_name: 'Areyou',
                                                              given_name: 'Who',
                                                              name: 'Who Areyou',
                                                              preferred_username: 'test456@princeton.edu',
                                                              unique_name: 'test456@princeton.edu',
                                                              # rest of the keys are present
                                                              #  They are set to values I do not understand,
                                                              #  so we don't care about them for this test
                                                              acct: nil, acr: nil, acrs: nil, aio: nil, amr: nil,
                                                              appid: nil, appidacr: nil, aud: nil, exp: nil,
                                                              iat: nil, idtyp: nil, ipaddr: nil, iss: nil, nbf: nil,
                                                              oid: nil, onprem_sid: nil, platf: nil,
                                                              puid: nil, rh: nil, roles: nil, scp: nil, sid: nil,
                                                              sub: nil, tenant_region_scope: nil, tid: nil,
                                                              upn: nil, uti: nil, ver: nil, wids: nil, xms_acd: nil,
                                                              xms_act_fct: nil, xms_ftd: nil, xms_idrel: nil,
                                                              xms_pftexp: nil, xms_st: nil, xms_sub_fct: nil,
                                                              xms_tcdt: nil, xms_tnt_fct: nil)
                           ))
  end
  let(:warden_proxy) { instance_double Warden::Proxy, authenticated?: false, user: nil, set_user: true }
  let(:env) { { 'omniauth.auth' => auth_hash, 'warden' => warden_proxy } }

  let(:user_repo) { OrcidPrinceton::Repos::UserRepo.new }

  it 'creates a new user and redirects' do
    response = subject.call(env)
    expect(response).to be_redirect
    expect(response.location).to eq Hanami.app.router.path(:root)
    expect(response.flash.next[:notice]).to eq('You were successfully authenticated')
    user = user_repo.last
    expect(user.uid).to eq('test456')
    expect(user.given_name).to eq('Who')
    expect(user.family_name).to eq('Areyou')
    expect(user.display_name).to eq('Who Areyou')
  end

  context 'no auth token' do
    let(:env) { { 'omniauth.auth' => nil, 'warden' => warden_proxy } }

    it 'redirects with an error and notifies Honeybadger' do
      allow(Honeybadger).to receive(:notify)
      response = subject.call(env)
      expect(response).to be_redirect
      expect(response.location).to eq Hanami.app.router.path(:root)
      expect(response.flash.next[:notice]).to eq('You are not authorized')
      expect(Honeybadger).to have_received(:notify).with('Entra ID login failed: OmniAuth auth hash is missing')
    end
  end

  context 'when user registration/retrieval fails with a Failure monad' do
    before do
      allow(Honeybadger).to receive(:notify)
      # Cause the operation to fail
      mock_operation = instance_double(OrcidPrinceton::Operations::UserFromEntraAttributes)
      allow(mock_operation).to receive(:call)
        .and_return(Dry::Monads::Result::Failure.new('LDAP lookup failed'))
      allow(OrcidPrinceton::Operations::UserFromEntraAttributes).to receive(:new).and_return(mock_operation)
    end

    it 'redirects with an error and notifies Honeybadger of the specific failure' do
      response = subject.call(env)
      expect(response).to be_redirect
      expect(response.location).to eq Hanami.app.router.path(:root)
      expect(response.flash.next[:notice]).to eq('You are not authorized')
      expect(Honeybadger).to have_received(:notify).with('Entra ID login failed: LDAP lookup failed',
                                                         context: { uid: 'test456' })
    end
  end

  context 'when an exception occurs' do
    before do
      allow(Honeybadger).to receive(:notify)
      allow(subject.user_repo).to receive(:from_entra_id)
        .and_raise(StandardError.new('Unexpected DB Connection Failure'))
    end

    it 'redirects with an error, catches the exception and logs to Honeybadger with context' do
      response = subject.call(env)
      expect(response).to be_redirect
      expect(response.location).to eq Hanami.app.router.path(:root)
      expect(response.flash.next[:notice]).to eq('You are not authorized')
      expect(Honeybadger).to have_received(:notify).with(
        an_instance_of(StandardError),
        context: hash_including(auth_hash: an_instance_of(Hash))
      )
    end

    context 'and the auth hash cannot be converted to a Hash for Honeybadger context' do
      let(:auth_hash) do
        Object.new.tap do |obj|
          def obj.to_h
            raise StandardError, 'cannot convert auth hash'
          end
        end
      end

      it 'notifies Honeybadger with a nil auth_hash context' do
        response = subject.call(env)
        expect(response).to be_redirect
        expect(response.location).to eq Hanami.app.router.path(:root)
        expect(response.flash.next[:notice]).to eq('You are not authorized')
        expect(Honeybadger).to have_received(:notify).with(
          an_instance_of(StandardError),
          context: { auth_hash: nil }
        )
      end
    end
  end
end
