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

    # Only deployed environments have a collector shipping structured events to
    # our observability stack, so they are the only ones paying for a JSON copy.
    ENVIRONMENTS_NEEDING_SIGNOZ = %w[production staging].freeze

    # Where we want the running commentary of a chatty log rather than the
    # summary a deployed environment needs.
    VERBOSE_ENVIRONMENTS = %w[development test].freeze

    LEVEL_VARIABLE = 'HANAMI_LOG_LEVEL'

    class << self
      # Builds the logger to hand to Hanami's `config.logger=`.
      def build(env:, root:, level: default_level(env), service_name: 'orcid')
        SemanticLogger.default_level = level.to_sym
        SemanticLogger.application = service_name
        SemanticLogger.environment = env.to_s

        add_appender(path: path(root: root, env: env, extension: TEXT_EXTENSION), formatter: :color)
        if ships_to_signoz?(env)
          add_appender(path: path(root: root, env: env, extension: JSON_EXTENSION), formatter: :json)
        end

        HanamiLogger.new(SemanticLogger[service_name])
      end

      # Path of a log file for an environment, e.g. log/staging.json.
      def path(root:, env:, extension:)
        root.join('log', "#{env}.#{extension}")
      end

      def ships_to_signoz?(env)
        ENVIRONMENTS_NEEDING_SIGNOZ.include?(env.to_s)
      end

      # Matches the levels Hanami itself picks, and stays overridable the same
      # way, so switching loggers does not change how an environment is tuned.
      def default_level(env)
        override = ENV.fetch(LEVEL_VARIABLE, nil)
        return override.to_sym if override && !override.empty?

        VERBOSE_ENVIRONMENTS.include?(env.to_s) ? :debug : :info
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

      # The attributes Hanami's own logger hides. Request logs include the
      # submitted parameters, so replacing that logger without honouring these
      # would start writing secrets to disk.
      FILTERED_ATTRIBUTES = %w[_csrf password password_confirmation].freeze
      FILTERED = '[FILTERED]'

      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      LEVELS.each do |level|
        define_method(level) do |message = nil, **details, &block|
          payload = filter(details)
          logger.public_send(level, message, payload.empty? ? nil : payload, &block)
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

      private

      def filter(value)
        case value
        when Hash
          value.to_h { |key, nested| [key, filtered?(key) ? FILTERED : filter(nested)] }
        when Array
          value.map { |item| filter(item) }
        else
          value
        end
      end

      def filtered?(key)
        FILTERED_ATTRIBUTES.include?(key.to_s)
      end
    end
  end
end
