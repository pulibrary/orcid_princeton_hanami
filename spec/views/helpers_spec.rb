# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Views::Helpers do
  # A dummy class to include the module for testing
  let(:helper_class) do
    Class.new do
      include OrcidPrinceton::Views::Helpers
    end
  end
  let(:helper) { helper_class.new }

  describe '#login_path' do
    context 'when the entra_id_login feature flag is disabled' do
      before do
        allow(Flipflop).to receive(:entra_id_login?).and_return(false)
      end

      it 'returns the default CAS path' do
        expect(helper.login_path).to eq("/auth/#{Hanami.app.settings.default_auth_provider}")
      end
    end

    context 'when the entra_id_login feature flag is enabled' do
      before do
        allow(Flipflop).to receive(:entra_id_login?).and_return(true)
      end

      it 'returns the Entra ID path' do
        expect(helper.login_path).to eq('/auth/entra_id')
      end
    end
  end
end
