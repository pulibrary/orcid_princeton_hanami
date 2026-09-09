# frozen_string_literal: true

require 'fileutils'
require 'semantic_logger'

module OrcidPrinceton
  # Sends application logs to two files at once: the plain text log people read
  # when they are on a server, and a newline delimited JSON copy that our
  # observability stack indexes as structured events.
  #
  # Both files live in the app's log directory, which the deploy tooling links to
  # shared/log, so log rotation and the log collector pick them up without any
  # extra configuration.
  module Logging
    TEXT_EXTENSION = 'log'
    JSON_EXTENSION = 'json'

    class << self
      # Builds the logger to hand to Hanami's `config.logger=`.
      def build(env:, root:, level: :info, service_name: 'orcid')
        SemanticLogger.default_level = level
        SemanticLogger.application = service_name
        SemanticLogger.environment = env.to_s

        add_appender(path: path(root: root, env: env, extension: TEXT_EXTENSION), formatter: :default)
        add_appender(path: path(root: root, env: env, extension: JSON_EXTENSION), formatter: :json)

        HanamiLogger.new(SemanticLogger[service_name])
      end

      # Path of a log file for an environment, e.g. log/staging.json.
      def path(root:, env:, extension:)
        root.join('log', "#{env}.#{extension}")
      end

      # Detaches the log files so a fresh set can be attached. Intended for tests.
      def reset!
        SemanticLogger.clear_appenders!
        @appended_paths = nil
      end

      private

      # Booting twice in one process would otherwise attach a second appender to
      # the same file and write every entry twice.
      def add_appender(path:, formatter:)
        path = path.to_s
        return if appended_paths.include?(path)

        FileUtils.mkdir_p(File.dirname(path))
        SemanticLogger.add_appender(file_name: path, formatter: formatter)
        appended_paths << path
      end

      def appended_paths
        @appended_paths ||= []
      end
    end

    # Adapts Semantic Logger to the logger interface Hanami expects.
    #
    # Hanami hands its request details to the logger as keyword arguments, and
    # falls back to serializing them into one long string unless the logger
    # advertises that it accepts them. Semantic Logger takes those details as a
    # positional hash instead, so without this shim every request would be
    # recorded as JSON nested inside a JSON string, which defeats the point of
    # structured logging.
    class HanamiLogger
      LEVELS = %i[debug info warn error fatal].freeze

      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      LEVELS.each do |level|
        define_method(level) do |message = nil, **details, &block|
          logger.public_send(level, message, details.empty? ? nil : details, &block)
        end
      end

      def tagged(*tags, &)
        logger.tagged(*tags, &)
      end

      def respond_to_missing?(name, include_private = false)
        logger.respond_to?(name, include_private) || super
      end

      def method_missing(name, ...)
        return super unless logger.respond_to?(name)

        logger.public_send(name, ...)
      end
    end
  end
end
