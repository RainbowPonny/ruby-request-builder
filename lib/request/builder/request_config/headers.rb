module Request
  module Builder
    class RequestConfig::Headers < Request::Builder::RequestConfig::Base
      def header(key, value = nil, &block)
        raise ArgumentError, 'Must provide a value or block' if !value && !block

        store[key] = block || value
      end

      private

      def store
        @store ||= HashWithIndifferentAccess.new
      end
    end
  end
end
