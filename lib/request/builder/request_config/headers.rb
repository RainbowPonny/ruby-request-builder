module Request
  module Builder
    class RequestConfig::Headers < Request::Builder::RequestConfig::Base
      def header(key, value = nil, &block)
        raise ArgumentError, 'Must provide a value or block' unless value || block

        store[key] = block.nil? ? value : block
      end

      private

      def store
        @store ||= {}
      end
    end
  end
end
