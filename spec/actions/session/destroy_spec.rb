# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Session::Destroy do
  let(:params) { Hash[] }

  it "does not fail if no user is logged in, just redirects to root" do
    response = subject.call(params)
    expect(response).to be_redirect
  end

  context "A user is logged in" do
    let(:user) { Factory[:admin] }
    let(:warden_manager) { Warden::Manager.new({}) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager), 'rack.session' => {} ] }

    it 'logs the user out and redirects to root' do
      params['warden'].set_user user.uid
      response = subject.call(params)
      byebug
      expect(response[:current_user]).to be_nil
      expect(response.env['warden'].user).to be_nil
      expect(response).to be_redirect
    end
  end
end
