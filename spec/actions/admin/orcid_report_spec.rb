# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Admin::OrcidReport do
  let(:params) { {} }

  it 'works' do
    response = subject.call(params)
    expect(response).to be_redirect
  end

  context 'a user is logged in' do
    let(:user) { Factory[:user] }
    let(:warden_manager) { Warden::Manager.new(nil) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager)] }

    it 'redirects to root' do
      params['warden'].set_user user.uid
      response = subject.call(params)
      expect(response).to be_redirect
      expect(response.flash.next[:notice]).to eq('You are not authorized')
    end
  end

  context 'an admin user is logged' do
    let(:user) { Factory[:admin] }
    let(:warden_manager) { Warden::Manager.new(nil) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager)] }

    it 'shows the logged in user info' do
      params['warden'].set_user user.uid
      response = subject.call(params)
      expect(response).to be_successful
      expect(response.headers['Content-Type']).to eq('text/csv; charset=utf-8')
      expect(response.body.count).to eq(1)
      expect { CSV.parse(response.body.first) }.not_to raise_error
    end
  end
end
