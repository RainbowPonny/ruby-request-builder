
require "dry-initializer"
require "dry-schema"
require "active_support/hash_with_indifferent_access"
require "active_support/core_ext/module/delegation"
require_relative "builder/version"
require_relative "builder/value_with_context"
require_relative "builder/request_config"
require_relative "builder/result"
require_relative "builder/dsl"
require_relative "builder/connection"

module Request
  module Builder
    def self.included(base)
      base.extend ClassMethods
      base.extend Dry::Initializer
      base.include Request::Builder::Dsl
      base.include Request::Builder::Connection

      class << base
        alias_method :__new, :new
        def new(*args, **kwargs)
          e = __new(*args, **kwargs)
          e.send(:set_config_context)
          e
        end
      end
    end

    module ClassMethods
      def call(*args, **kwargs)
        new(*args, **kwargs).call
      end
      alias perform call
    end

    def self.default_adapter(adapter = nil)
      @default_adapter = adapter if adapter

      @default_adapter || :net_http
    end

    def call
      do_request
      result
    end
    alias perform call

    private

    attr_reader :response

    def result
      @result ||= Result.new(response, self)
    end

    def do_request
      @response = connection.send(config.method.downcase, config.path) do |req|
        req.options.timeout = config.timeout

        config.each_param do |key, value|
          req.params[key] = value
        end

        config.each_header do |key, value|
          req.headers[key] = value
        end

        req.body = config.body
      end
    end

    def set_config_context
      config.context = self
    end
  end
end
