# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Operations::ValidateUserTokens do
  let(:user_repo) { OrcidPrinceton::Repos::UserRepo.new }

  it 'raises an error for a bad user' do
    validate_tokens = described_class.new
    result = validate_tokens.call(2002)
    expect(result).to be_a Dry::Monads::Result::Failure
    expect(result.failure).to eq('The user does not exists')
  end

  context 'when the token is still valid' do
    let(:user) { Factory[:user_with_orcid_and_token] }
    let(:warden_manager) { Warden::Manager.new(nil) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager), id: user.id.to_s] }

    it 'checks the tokens' do
      stub_request(:get, "https://api.sandbox.orcid.org/v3.0/#{user.orcid}/record").to_return(status: 200, body: '',
                                                                                              headers: {})
      validate_tokens = described_class.new
      result = validate_tokens.call(user.id)
      expect(result).to be_a Dry::Monads::Result::Success
      updated_user = user_repo.get(user.id)
      expect(updated_user.tokens_expired?).to be_falsey
    end
  end

  context 'when the token is not valid' do
    let(:user) { Factory[:user_with_orcid_and_token] }
    let(:warden_manager) { Warden::Manager.new(nil) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager), id: user.id.to_s] }

    it 'checks the tokens' do
      stub_request(:get, "https://api.sandbox.orcid.org/v3.0/#{user.orcid}/record").to_return(status: 201, body: '',
                                                                                              headers: {})
      validate_tokens = described_class.new
      result = validate_tokens.call(user.id)
      expect(result).to be_a Dry::Monads::Result::Success
      updated_user = user_repo.get(user.id)
      expect(updated_user.tokens_expired?).to be_truthy
    end
  end
end
