# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Structs::User do
  let(:rom_user) { Factory[:user] }
  subject(:user) { OrcidPrinceton::Repos::UserRepo.new.get(rom_user.id) }

  describe '#admin?' do
    it 'is false by default' do
      expect(user).not_to be_admin
    end
  end

  context 'an admin user' do
    let(:rom_user) { Factory[:admin] }

    describe '#admin?' do
      it 'is true' do
        expect(user).to be_admin
      end
    end
  end
end
