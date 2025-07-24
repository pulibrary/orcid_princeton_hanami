# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Service::EncryptionHelper, type: :service do
  it 'encrypts and then decrypyts the value' do
    helper = described_class.new
    encrypted_value = helper.encrypt('253e5364-eb30-4cbb-83be-3e5c9ce3b0bc')
    expect(encrypted_value).not_to eq('253e5364-eb30-4cbb-83be-3e5c9ce3b0bc')
    expect(encrypted_value).to include(':')
    expect(helper.decrypt(encrypted_value)).to eq('253e5364-eb30-4cbb-83be-3e5c9ce3b0bc')
  end
end
