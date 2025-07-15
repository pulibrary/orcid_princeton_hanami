# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Repos::RoleRepo do
  subject(:repo) do
    described_class.new
  end

  describe '#admin_role' do
    it 'returns a the admin role' do
      admin_role = repo.admin_role
      expect(admin_role.name).to eq('admin')
      expect(repo.admin_role).to eq(admin_role)
    end
  end
end
