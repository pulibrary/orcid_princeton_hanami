# frozen_string_literal: true

otel_env = File.expand_path('.otel.env', __dir__)

if File.exist?(otel_env)
  File.readlines(otel_env).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    next unless line.start_with?('export ')

    key, value = line.sub(/\Aexport\s+/, '').split('=', 2)
    ENV[key] = value if key && value
  end
end

require_relative 'config/initializers/opentelemetry'

require 'hanami/boot'

run Hanami.app
