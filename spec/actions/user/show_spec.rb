# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::User::Show do
  let(:params) { {} }

  it 'redirects to login' do
    response = subject.call(params)
    expect(response).to be_redirect
  end

  context 'a user is logged in' do
    let(:user) { Factory[:user] }
    let(:warden_manager) { Warden::Manager.new(nil) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager), id: user.id.to_s] }

    it 'renders html' do
      params['warden'].set_user user.uid
      response = subject.call(params)
      expect(response).to be_successful
    end

    context 'the user wants json' do
      let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager), id: "#{user.id}.json"] }

      it 'renders json' do
        params['warden'].set_user user.uid
        response = subject.call(params)
        expect(response).to be_successful
        json_data = JSON.parse(response.body.first)
        expect(json_data['id']).to eq(user.id)
        expect(json_data['uid']).to eq(user.uid)
        expect(json_data['url']).to eq("http://0.0.0.0:2300/users/#{user.id}.json")
      end
    end
  end
end
