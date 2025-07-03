# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Session::Create do
  let(:university_id) { '999999999' }
  let(:auth_hash) do
    OmniAuth::AuthHash.new(provider: 'cas', uid: 'test123',
                           extra: OmniAuth::AuthHash.new(mail: 'who@princeton.edu', user: 'test123',
                                                         authnContextClass: 'mfa-duo', campusid: 'who.areyou',
                                                         puresidentdepartmentnumber: '41999', uid: 'test123',
                                                         title: 'The Developer, Library - Information Technology.',
                                                         universityid: university_id, displayname: 'Areyou, Who',
                                                         pudisplayname: 'Areyou, Who',
                                                         edupersonaffiliation: 'staff', givenname: 'Who',
                                                         sn: 'Areyou', department: 'Library - Information Technology',
                                                         edupersonprincipalname: 'who@princeton.edu',
                                                         puresidentdepartment: 'Library - Information Technology',
                                                         puaffiliation: 'stf', departmentnumber: '41999',
                                                         pustatus: 'stf'))
  end
  let(:warden_proxy) { instance_double Warden::Proxy, "authenticated?": false, user: nil, set_user: true }
  let(:env) { { 'omniauth.auth' => auth_hash, 'warden' => warden_proxy } }

  let(:user_repo) { OrcidPrinceton::Repos::UserRepo.new }

  it 'creates a new user and redirects' do
    response = subject.call(env)
    expect(response).to be_redirect
    expect(response.location).to eq Hanami.app.router.path(:health)
    expect(response.flash.next[:notice]).to eq('You were successfully authenticated')
    user = user_repo.last
    expect(user.uid).to eq('test123')
  end

  context 'no auth token' do
    let(:env) { { 'omniauth.auth' => nil, 'warden' => warden_proxy } }

    it 'redirects with an error' do
      response = subject.call(env)
      expect(response).to be_redirect
      expect(response.location).to eq Hanami.app.router.path(:health)
      expect(response.flash.next[:notice]).to eq('You are not authorized')
    end
  end
end
