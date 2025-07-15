# frozen_string_literal: true

# Code was found at https://umarfarooquekhan.medium.com/encrypting-and-decrypting-data-in-ruby-using-openssl-07a9331e8166
require 'openssl'
module OrcidPrinceton
  module Service
    # Allow a value to be encrypted and decrypted
    class EncryptionHelper
      attr_reader :secret_key, :iv_length, :algorithm

      def initialize(secret_key: ENV['OPENSSL_KEY'], algorithm: ENV['OPENSSL_ALGORITHM'],
                     iv_length: ENV['OPENSSL_IV_LEN'].to_i)
        @secret_key = secret_key
        @algorithm = algorithm
        @iv_length = iv_length
      end

      # Method to encrypt a value
      def encrypt(value)
        return nil if value.nil? || value.strip.empty? # Handle empty input

        iv = OpenSSL::Random.random_bytes(iv_length) # Generate a random IV
        cipher = OpenSSL::Cipher.new(algorithm).encrypt # Create cipher in encryption mode
        cipher.key = secret_key # Set encryption key
        cipher.iv = iv # Set IV
        encrypted = cipher.update(value) + cipher.final # Perform encryption
        "#{iv.unpack1('H*')}:#{encrypted.unpack1('H*')}" # Convert to hex format and return
      end

      # Method to decrypt a value
      def decrypt(encrypted_string)
        return nil if encrypted_string.nil? || encrypted_string.strip.empty? # Handle empty input

        iv_hex, encrypted_hex = encrypted_string.split(':') # Split IV and encrypted data
        return nil unless iv_hex && encrypted_hex # Validate input format

        cipher = OpenSSL::Cipher.new(algorithm).decrypt # Create cipher in decryption mode
        cipher.key = secret_key # Set decryption key
        cipher.iv = [iv_hex].pack('H*') # Convert IV from hex to bytes
        cipher.update([encrypted_hex].pack('H*')) + cipher.final # Perform decryption
      end
    end
  end
end
