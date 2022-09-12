module Request
  module Builder
    class RequestConfig
      attrs = {
        host: nil,
        path: nil,
        method: :get,
        request_middleware: :json,
        response_middleware: :json,
        adapter: :net_http,
        logger: nil,
        timeout: 30
      }

      attr_reader :context
      attr_writer *attrs.keys

      not_provided = Object.new

      attrs.each do |attr, default_value|
        define_method attr do |value = not_provided, &block|
          if value === not_provided && block.nil?
            result = instance_variable_get("@#{attr}") || default_value
            result.is_a?(Proc) ? instance_eval { result.call(context) } : result
          else
            instance_variable_set("@#{attr}", block || value)
          end
        end
      end

      def schema(value = nil, &block)
        if value.nil? && block.nil?
          @response_schema || Dry::Schema.Params
        else
          @response_schema = Dry::Schema.Params(&block) || value
        end
      end

      def body(&block)
        @body ||= RequestConfig::Body.new

        return @body.set(&block) if block

        @body
      end

      def headers(&block)
        @headers ||= RequestConfig::Headers.new

        @headers.instance_eval(&block) if block_given?

        @headers
      end

      def header(key, value = nil, &block)
        headers.header(key, value, &block)
      end

      def params(&block)
        @params ||= RequestConfig::Params.new

        @params.instance_eval(&block) if block_given?

        @params
      end

      def param(key, value = nil, &block)
        params.param(key, value, &block)
      end

      def context=(context)
        @context = context
        body.context = context
        headers.context = context
        params.context = context
      end

      def [] property
        instance_variable_get("@#{property}".to_sym)
      end

      Module.new do
        singleton_class.send :define_method, :included do |host_class|
          host_class.extend class_methods
        end
      end
    end
  end
end
