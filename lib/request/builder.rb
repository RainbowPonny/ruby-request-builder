
require "dry-initializer"
require "dry-schema"
require 'active_support/all'
require_relative "builder/version"
require_relative "builder/request_config"
require_relative "builder/value_with_context"
require_relative "builder/request_config/base"
require_relative "builder/request_config/body"
require_relative "builder/request_config/params"
require_relative "builder/request_config/headers"
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
    end

    attr_reader :response

    module ClassMethods
      def call(**args)
        new(**args).call
      end
      alias perform call
    end

    def call
      set_context
      do_request
      result
    end
    alias perform call

    def result
      @result ||= Result.new(response, self)
    end

    def do_request
      @response = connection.send(config.method.downcase, config.path) do |req|
        req.options.timeout = config.timeout

        config.params.each do |key, value|
          req.params[key] = value
        end

        config.headers.each do |key, value|
          req.headers[key] = value
        end

        req.body = config.body.call
      end
    end

    def set_context
      config.context = self
    end
  end
end
