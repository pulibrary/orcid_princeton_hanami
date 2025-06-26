# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Repos::UserRepo do
  subject(:repo) do
    described_class.new
  end

  describe '#create' do
    it 'creates a users and sets the times' do
      user = repo.create(given_name: 'Sally', family_name: 'Smith', uid: 'ss123', display_name: 'Sally Smith',
                         provider: 'other', university_id: '1234567890')
      expect(user.id).not_to be_blank
      expect(user.given_name).to eq('Sally')
      expect(user.family_name).to eq('Smith')
      expect(user.display_name).to eq('Sally Smith')
      expect(user.university_id).to eq('1234567890')
      expect(user.created_at).not_to be_blank
      expect(user.updated_at).not_to be_blank
      expect(user.updated_at).to eq(user.created_at)
    end
  end

  describe '#last' do
    it 'loads the last item' do
      Factory[:user] # create a random user to be certain we are getting the last one
      last_user = Factory[:user, university_id: '111345']
      user = repo.last
      expect(user.id).to eq(last_user.id)
      expect(user.given_name).to eq(last_user.given_name)
      expect(user.family_name).to eq(last_user.family_name)
      expect(user.display_name).to eq(last_user.display_name)
      expect(user.university_id).to eq('111345')
    end
  end

  describe '#get' do
    it 'loads the user' do
      first_user = Factory[:user, uid: 'bb456']
      Factory[:user, university_id: '111345'] # create a random user to be certain we are getting the right one
      user = repo.get(first_user.id)
      expect(user.id).to eq(first_user.id)
      expect(user.uid).to eq('bb456')
      expect(user.given_name).to eq(first_user.given_name)
      expect(user.family_name).to eq(first_user.family_name)
      expect(user.display_name).to eq(first_user.display_name)
      expect(user.university_id).to eq(first_user.university_id)
    end
  end

  describe '#update' do
    it 'updates a users and sets the update time' do
      user = Factory[:user]
      repo.update(user.id, family_name: 'Smith')
      updated_user = repo.last

      expect(updated_user.id).to eq(user.id)
      expect(updated_user.given_name).to eq(user.given_name)
      expect(updated_user.family_name).to eq('Smith')
      expect(updated_user.created_at).not_to eq(updated_user.updated_at)
    end
  end
end
