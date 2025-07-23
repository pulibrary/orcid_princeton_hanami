# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::User::ValidateTokens do
  let(:params) { {} }

  it 'redirects to login' do
    response = subject.call(params)
    expect(response).to be_redirect
  end

  context 'a user is logged in' do
    let(:user) { Factory[:user_with_orcid_and_token] }
    let(:warden_manager) { Warden::Manager.new(nil) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager), id: user.id.to_s] }

    it 'checks the tokens' do
      stub_request(:get, "https://api.sandbox.orcid.org/v3.0/#{user.orcid}/record").to_return(status: 200, body: '',
                                                                                              headers: {})
      params['warden'].set_user user.uid
      response = subject.call(params)
      expect(response).to be_redirect
      expect(a_request(:get, "https://api.sandbox.orcid.org/v3.0/#{user.orcid}/record")).to have_been_made.once
    end
  end
end
