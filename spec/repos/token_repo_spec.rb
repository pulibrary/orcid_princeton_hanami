# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Repos::TokenRepo do
  subject(:repo) do
    described_class.new
  end

  describe '#get' do
    it 'loads the token' do
      first_token = Factory[:token]
      Factory[:token, token: '111345'] # create a random to to be certain we are getting the right one
      token = repo.get(first_token.id)
      expect(token.id).to eq(first_token.id)
      expect(token.token).to eq(first_token.token)
    end
  end

  describe '#update' do
    it 'updates a token and sets the update time' do
      token = Factory[:token]
      repo.update(token.id, token_type: 'test', token: 'token-new')
      updated_token = repo.last

      expect(updated_token.id).to eq(token.id)
      expect(updated_token.token_type).to eq('test')
      expect(updated_token.token).to eq('token-new')
      expect(updated_token.created_at).not_to eq(updated_token.updated_at)
    end
  end
end
