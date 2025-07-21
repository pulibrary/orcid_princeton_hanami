# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Orcid::Failure do
  let(:warden_proxy) { instance_double Warden::Proxy, "authenticated?": true, user: user.id, set_user: true }
  let(:env) { { 'omniauth.error' => Exception.new('Error with Auth'), 'warden' => Warden::Proxy.new({}, warden_manager) } }

  let(:user) { Factory[:user_with_orcid] }
  let(:warden_manager) { Warden::Manager.new(nil) }

  it 'works' do
    env['warden'].set_user user.uid
    response = subject.call(env)
    expect(response).to be_redirect
    expect(response.flash.next[:notice]).to eq('Omniauth linking failed Error with Auth (Exception).  ' \
                                               'Consider linking your account')
  end
end
