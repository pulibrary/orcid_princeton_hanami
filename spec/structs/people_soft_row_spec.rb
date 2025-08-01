# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Structs::PeopleSoftRow do
  subject(:row) do
    described_class.new(university_id: 'id', netid: 'abc123', full_name: 'Jane Doe',
                        orcid: 'orcid', effective_from: 'date', effective_until: 'date2')
  end

  describe '#university_id' do
    it 'has a getter' do
      expect(row.university_id).to eq('id')
    end
  end

  describe '#netid' do
    it 'has a getter' do
      expect(row.netid).to eq('abc123')
    end
  end

  describe '#row_type' do
    it 'is set to ORC by default' do
      expect(row.row_type).to eq('ORC')
    end

    context 'the row_type is set' do
      subject(:row) do
        described_class.new(row_type: 'other', university_id: 'id', netid: 'abc123', full_name: 'Jane Doe',
                            orcid: 'orcid', effective_from: '', effective_until: '')
      end
      it 'is set to the value' do
        expect(row.row_type).to eq('other')
      end
    end
  end

  describe '#full_name' do
    it 'has a getter' do
      expect(row.full_name).to eq('Jane Doe')
    end
  end

  describe '#effective_from' do
    it 'has a getter' do
      expect(row.effective_from).to eq('date')
    end
  end

  describe '#effective_until' do
    it 'has a getter' do
      expect(row.effective_until).to eq('date2')
    end
  end

  describe '##new_from_user' do
    it 'creates a row from a user' do
      rom_user = Factory[:user_with_orcid_and_token]
      user = OrcidPrinceton::Repos::UserRepo.new.get(rom_user.id)
      row = described_class.new_from_user(user)
      expect(row.netid).to eq(user.uid)
      expect(row.university_id).to eq(user.university_id)
      expect(row.row_type).to eq('ORC')
      expect(row.full_name).to eq(user.display_name)
      expect(row.orcid).to eq(user.orcid)
      expect(row.effective_from).to eq(user.valid_token.created_at.strftime('%m/%d/%Y'))
      expect(row.effective_until).to eq(user.valid_token.expiration.strftime('%m/%d/%Y'))
    end
  end
end
