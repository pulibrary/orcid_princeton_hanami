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

    it 'passes unknown calls through to Semantic Logger' do
      expect(logger).to respond_to(:level)
      expect(logger.level).to eq(:info)
    end
  end
end
