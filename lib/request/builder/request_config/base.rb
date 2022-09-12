module Request
  module Builder
    class RequestConfig::Base
      include ValueWithContext

      attr_accessor :context
      attr_reader :store

      delegate_missing_to :context

      def initialize(context = nil)
        @context = context
      end

      def each(&block)
        raise NotImplementedError unless store.is_a?(Enumerable)

        store.each do |value|
          value[1] = value_with_context(value[1])
          block.call(value)
        end
      end

      private

      def store
        raise NotImplementedError
      end
    end
  end
end
