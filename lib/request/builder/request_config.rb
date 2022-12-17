module Request
  module Builder
    class RequestConfig
      include ValueWithContext

      delegate_missing_to :context

      attrs = [:params, :callbacks, :headers, :body, :host, :path, :method, :request_middleware, :response_middleware, :adapter, :logger, :timeout]

      attr_reader :context, :stubs
      attr_writer *attrs, :stubs, :context

      def initialize(**params)
        @body = params[:body]
        @host = params[:host]
        @path = params[:path] || '/'
        @method = params[:method] ||:get
        @request_middleware = params[:request_middleware] || :json
        @response_middleware = params[:response_middleware] || :json
        @adapter = params[:adapter] || Request::Builder.default_adapter
        @stubs = params[:stubs] || Faraday::Adapter::Test::Stubs.new
        @logger = params[:logger]
        @timeout = params[:timeout] || 30
        @response_schema = params[:response_schema] || Dry::Schema.Params
        @context = nil
        @body = params[:body]
        @params = params[:params] || HashWithIndifferentAccess.new
        @headers = params[:headers] || HashWithIndifferentAccess.new
        @callbacks = params[:callbacks] || HashWithIndifferentAccess.new
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
          callbacks[name] = block
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

      def header(key, value = nil, &block)
        if value.nil? && block.nil?
          value_with_context(headers[key])
        else
          headers[key] = block || value
        end
      end

      def param(key, value = nil, &block)
        if value.nil? && block.nil?
          value_with_context(params[key])
        else
          params[key] = block || value
        end
      end

      def each_header
        headers.each do |key, value|
          yield key, value_with_context(value)
        end
      end

      def each_param
        params.each do |key, value|
          yield key, value_with_context(value)
        end
      end

      def [] property
        instance_variable_get("@#{property}".to_sym)
      end

      def dup
        Request::Builder::RequestConfig.new(
          body: @body.dup,
          host: @host.dup,
          path: @path.dup,
          method: @method,
          request_middleware: @request_middleware,
          response_middleware: @response_middleware,
          adapter: @adapter,
          stubs: @stubs,
          logger: @logger,
          timeout: @timeout,
          response_schema: @response_schema,
          body: @body.dup,
          params: @params.dup,
          headers: @headers.dup,
          callbacks: @callbacks.dup
        )
      end

      Module.new do
        singleton_class.send :define_method, :included do |host_class|
          host_class.extend class_methods
        end
      end
    end
  end
end
