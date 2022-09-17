require "faraday"
require "faraday_middleware"

module Request
  module Builder
    module Connection
      private

      def connection
        @_connection ||= Faraday.new(url: config.host) do |builder|
          builder.adapter config.adapter, config.stubs
          builder.request config.request_middleware
          builder.response config.response_middleware
          builder.response(:logger, config.logger, bodies: true) if config.logger
        end
      end
    end
  end
end
