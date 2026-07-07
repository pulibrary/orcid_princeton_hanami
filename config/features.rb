# frozen_string_literal: true

require 'flipflop'
require 'flipflop/strategies/abstract_strategy'

# Custom Flipflop strategy to read feature flags from environment variables
class EnvironmentStrategy < Flipflop::Strategies::AbstractStrategy
  def name
    'env'
  end

  def description
    'Reads feature states from environment variables.'
  end

  # rubocop:disable Style/ReturnNilInPredicateMethodDefinition
  def enabled?(feature)
    value = ENV.fetch(feature.to_s.upcase, nil) || ENV.fetch("FEATURE_#{feature.to_s.upcase}", nil)
    if value.nil?
      nil
    else
      value == '1' || value.downcase == 'true'
    end
  end
  # rubocop:enable Style/ReturnNilInPredicateMethodDefinition
end

Flipflop.configure do
  strategy :cookie
  strategy EnvironmentStrategy.new
  strategy :default

  feature :entra_id_login,
          default: false,
          description: 'Use Microsoft Entra ID for user authentication instead of CAS'
end
