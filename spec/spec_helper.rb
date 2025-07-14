# frozen_string_literal: true

require 'axe-rspec'
require 'pathname'
require 'coveralls'
require 'byebug'
Coveralls.wear!

SPEC_ROOT = Pathname(__dir__).realpath.freeze

ENV['HANAMI_ENV'] ||= 'test'
require 'hanami/prepare'

SPEC_ROOT.glob('support/**/*.rb').each { |f| require f }
