module Request
  module Builder
    class Result
      attr_reader :response, :context, :body

      delegate :headers, :status, to: :response
      delegate :config, to: :context
      delegate :schema, to: :config
      delegate :errors, to: :schema_result

      def initialize(response, context)
        @response = response
        @context = context
        @before_validate = config.callbacks[:before_validate]
        @body = @before_validate ? @before_validate.call(response.body.to_h) : response.body.to_h
      end

      def success?
        status == 200 && schema_result.success?
      end

      def failure?
        !success?
      end

      def schema_result
        @schema_result ||= schema.call(body)
      end

      def full_errors
        errors(full: true).to_h
      end
    end
  end
end
