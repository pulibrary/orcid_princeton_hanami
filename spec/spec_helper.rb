# frozen_string_literal: true

require 'pathname'
require 'coveralls'
Coveralls.wear!

SPEC_ROOT = Pathname(__dir__).realpath.freeze

ENV['HANAMI_ENV'] ||= 'test'
require 'hanami/prepare'

SPEC_ROOT.glob('support/**/*.rb').each { |f| require f }
