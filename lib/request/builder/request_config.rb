module Request
  module Builder
    class RequestConfig
      include ValueWithContext

      delegate_missing_to :context

      attrs = [:host, :path, :method, :request_middleware, :response_middleware, :adapter, :logger, :timeout]

      attr_reader :context, :body_conf, :headers_conf, :params_conf, :callbacks_conf, :stubs
      attr_writer *attrs, :stubs

      alias callbacks callbacks_conf

      def initialize
        @host = nil
        @path = '/'
        @method = :get
        @request_middleware = :json
        @response_middleware = :json
        @adapter = :net_http
        @stubs = Faraday::Adapter::Test::Stubs.new
        @logger = nil
        @timeout = 30
        @body_conf = RequestConfig::Body.new
        @headers_conf = RequestConfig::Headers.new
        @params_conf = RequestConfig::Params.new
        @callbacks_conf = RequestConfig::Callbacks.new
        @response_schema = Dry::Schema.Params
      end

      attrs.each do |attr|
        define_method attr do |value = nil, &block|
          if value.nil? && block.nil?
            value_with_context(instance_variable_get("@#{attr}"))
          else
            instance_variable_set("@#{attr}", block || value)
          end
        end
      end

      [:before_validate].each do |name|
        define_method name do |&block|
          callbacks.send(name, &block)
        end
      end

      def stubs(value = nil, &block)
        if block_given?
          @stubs.instance_eval(&block)
        elsif value
          @stubs = value
        else
          @stubs
        end
      end

      def schema(value = nil, &block)
        if block_given?
          @response_schema = Dry::Schema.Params(&block)
        elsif value
          @response_schema = value
        else
          @response_schema
        end
      end

      def body(&block)
        return body_conf.set(&block) if block_given?

        body_conf.to_h
      end

      def headers(&block)
        headers_conf.instance_eval(&block) if block_given?

        headers_conf
      end

      def header(key, value = nil, &block)
        headers_conf.header(key, value, &block)
      end

      def params(&block)
        params_conf.instance_eval(&block) if block_given?

        params_conf
      end

      def param(key, value = nil, &block)
        params_conf.param(key, value, &block)
      end

      def context=(context)
        @context = context

        [body_conf, headers_conf, params_conf, callbacks_conf].each { |cnf| cnf.context = context }
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
