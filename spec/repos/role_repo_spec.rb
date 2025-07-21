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

  describe '#create' do
    it 'creates a role and sets the times' do
      role = repo.create(name: 'role1')
      expect(role.id).not_to be_blank
      expect(role.name).to eq('role1')
      expect(role.created_at).not_to be_blank
      expect(role.updated_at).not_to be_blank
      expect(role.updated_at).to eq(role.created_at)
    end
  end

  describe '#update' do
    it 'updates a role and sets the update time' do
      role = Factory[:role]
      repo.update(role.id, name: 'role_new')
      updated_role = repo.last

      expect(updated_role.id).to eq(role.id)
      expect(updated_role.name).to eq('role_new')
      expect(updated_role.created_at).not_to eq(updated_role.updated_at)
    end
  end
end
