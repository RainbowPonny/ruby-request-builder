module Request
  module Builder
    class RequestConfig::Body < Request::Builder::RequestConfig::Base
      def set(&block)
        raise ArgumentError, 'You must provide a block' unless block_given?

        @store = block
      end

      def to_h
        value_with_context(store)
      end

      private

      def store
        @store ||= nil
      end
    end
  end
end
