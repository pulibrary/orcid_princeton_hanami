# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Orcid::Create do
  let(:params) { {} }
  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(credentials:, uid: user.orcid)
  end
  let(:credentials) do
    OmniAuth::AuthHash.new(
      expires: true,
      expires_at: 2_329_292_554,
      refresh_token: '4daad3c0-5bcd-4d39-b505-a515b32d2f87',
      token: '253e5364-eb30-4cbb-83be-3e5c9ce3b0bc'
    )
  end
  let(:warden_proxy) { instance_double Warden::Proxy, "authenticated?": true, user: user.id, set_user: true }
  let(:env) { { 'omniauth.auth' => omniauth_hash, 'warden' => Warden::Proxy.new({}, warden_manager) } }

  let(:user) { Factory[:user_with_orcid] }
  let(:warden_manager) { Warden::Manager.new(nil) }

  let(:user_repo) { OrcidPrinceton::Repos::UserRepo.new }

  it 'works' do
    env['warden'].set_user user.uid
    response = subject.call(env)
    expect(response).to be_redirect

    updated_user = user_repo.get(user.id)

    expect(updated_user.tokens.count).to eq(1)
    encrypted_token = updated_user.tokens.first.attributes[:openssl_token]
    token = OrcidPrinceton::Service::EncryptionHelper.new.decrypt(encrypted_token)
    expect(token).to eq '253e5364-eb30-4cbb-83be-3e5c9ce3b0bc'
  end
end
