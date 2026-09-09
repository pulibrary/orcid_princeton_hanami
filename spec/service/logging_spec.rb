# frozen_string_literal: true

require 'spec_helper'
require_relative '../../config/initializers/semantic_logger'

RSpec.describe OrcidPrinceton::Logging do
  let(:root) { Pathname(Dir.mktmpdir) }
  let(:json_log) { root.join('log', 'staging.json') }
  let(:text_log) { root.join('log', 'staging.log') }

  after do
    OrcidPrinceton::Logging.reset!
    FileUtils.remove_entry(root)
    # These examples detach the log files the whole suite shares, so give the
    # rest of the suite its logging back.
    OrcidPrinceton::Logging.build(env: :test, root: Pathname(Dir.pwd))
  end

  def entries
    SemanticLogger.flush
    json_log.readlines.reject { |line| line.strip.empty? }.map { |line| JSON.parse(line) }
  end

  describe '.build' do
    it 'writes a plain text log and a JSON log side by side' do
      logger = described_class.build(env: :staging, root: root, level: :info)
      logger.info('hello')

      SemanticLogger.flush
      expect(text_log).to exist
      expect(json_log).to exist
    end

    it 'records each entry as a single line of JSON' do
      logger = described_class.build(env: :staging, root: root, level: :info)
      logger.info('a message', orcid: '0000-0001-0000-0001')

      entry = entries.last
      expect(entry['message']).to eq('a message')
      expect(entry['payload']).to eq('orcid' => '0000-0001-0000-0001')
      expect(entry['environment']).to eq('staging')
      expect(entry['level']).to eq('info')
    end

    it 'reports exceptions as structured data rather than a wall of text' do
      logger = described_class.build(env: :staging, root: root, level: :info)
      begin
        raise ArgumentError, 'no good'
      rescue ArgumentError => e
        logger.error(e)
      end

      expect(entries.last['exception']).to include('name' => 'ArgumentError', 'message' => 'no good')
    end

    it 'does not duplicate entries when the app is set up more than once' do
      described_class.build(env: :staging, root: root, level: :info)
      logger = described_class.build(env: :staging, root: root, level: :info)
      logger.info('only once')

      expect(entries.size).to eq(1)
    end

    it 'honours the requested level' do
      logger = described_class.build(env: :staging, root: root, level: :warn)
      logger.info('too quiet to record')
      logger.warn('loud enough')

      expect(entries.map { |entry| entry['message'] }).to eq(['loud enough'])
    end

    it 'keeps a readable log for environments without a log collector' do
      described_class.build(env: :development, root: root)

      expect(root.join('log', 'development.log')).to exist
      expect(root.join('log', 'development.json')).not_to exist
    end
  end

  describe '.default_level' do
    it 'is chatty where people are watching the log' do
      expect(described_class.default_level(:development)).to eq(:debug)
      expect(described_class.default_level(:test)).to eq(:debug)
    end

    it 'is quieter where the log is shipped somewhere' do
      expect(described_class.default_level(:staging)).to eq(:info)
      expect(described_class.default_level(:production)).to eq(:info)
    end

    it 'can be turned up without a deploy' do
      allow(ENV).to receive(:fetch).with('HANAMI_LOG_LEVEL', nil).and_return('debug')

      expect(described_class.default_level(:production)).to eq(:debug)
    end
  end

  describe OrcidPrinceton::Logging::HanamiLogger do
    subject(:logger) { OrcidPrinceton::Logging.build(env: :staging, root: root, level: :info) }

    # Hanami inspects the logger and silently downgrades to serializing its
    # request details into one long string unless this holds true.
    it 'accepts the keyword details Hanami passes to it' do
      expect(logger.method(:info).parameters).to include(%i[keyrest details])
    end

    it 'marks entries with the tags Hanami uses to identify request logs' do
      logger.tagged(:rack) { logger.info('GET /users') }

      expect(entries.last['tags']).to eq(['rack'])
    end

    it 'returns the value of the tagged block' do
      expect(logger.tagged(:rack) { 'the result' }).to eq('the result')
    end

    it 'hides the credentials people submit with a request' do
      logger.info('GET /users', params: { 'password' => 'secret', '_csrf' => 'token', 'orcid' => '0000' })

      expect(entries.last['payload']['params'])
        .to eq('password' => '[FILTERED]', '_csrf' => '[FILTERED]', 'orcid' => '0000')
    end

    it 'passes unknown calls through to Semantic Logger' do
      expect(logger).to respond_to(:level)
      expect(logger.level).to eq(:info)
    end
  end
end
