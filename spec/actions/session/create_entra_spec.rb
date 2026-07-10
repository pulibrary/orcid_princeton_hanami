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

    it 'redirects with an error' do
      response = subject.call(env)
      expect(response).to be_redirect
      expect(response.location).to eq Hanami.app.router.path(:root)
      expect(response.flash.next[:notice]).to eq('You are not authorized')
    end
  end
end
