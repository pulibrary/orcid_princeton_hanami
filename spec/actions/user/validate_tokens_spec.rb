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
    before do
      params['warden'].set_user user.uid
      stub_request(:get, "https://api.sandbox.orcid.org/v3.0/#{user.orcid}/record").to_return(status: 200, body: '',
                                                                                              headers: {})
    end

    it 'checks the tokens' do
      response = subject.call(params)
      expect(response).to be_redirect
      expect(a_request(:get, "https://api.sandbox.orcid.org/v3.0/#{user.orcid}/record")).to have_been_made.once
    end

    it "will not check other's tokens" do
      user2 = Factory[:user]
      params[:id] = user2.id
      response = subject.call(params)
      expect(response).to be_successful
      expect(a_request(:get, "https://api.sandbox.orcid.org/v3.0/#{user.orcid}/record")).not_to have_been_made
      expect(response.body.first).to include('Forbidden')
    end

    it 'notifies the user of an issue' do
      mock_validate = instance_double OrcidPrinceton::Operations::ValidateUserTokens, call: Failure('abc')
      allow(OrcidPrinceton::Operations::ValidateUserTokens).to receive(:new).and_return(mock_validate)
      response = subject.call(params)
      expect(response).to be_redirect
      expect(response.flash.next[:notice]).to eq('abc')
    end
  end
end
