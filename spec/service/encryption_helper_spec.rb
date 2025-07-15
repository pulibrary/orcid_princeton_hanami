# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Service::EncryptionHelper, type: :service do
  it 'encrypts and then decrypyts the value' do
    ENV['OPENSSL_KEY'] = '0123456789abcdef0123456789abcdef'[0, 32]
    ENV['OPENSSL_ALGORITHM'] = 'AES-256-CBC'
    ENV['OPENSSL_IV_LEN'] = 16.to_s
    helper = described_class.new
    encrypted_value = helper.encrypt('abc123')
    expect(encrypted_value).not_to eq('abc123')
    expect(encrypted_value).to include(':')
    expect(helper.decrypt(encrypted_value)).to eq('abc123')
  end
end
