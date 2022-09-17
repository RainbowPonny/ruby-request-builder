module Request
  module Builder
    class RequestConfig::Callbacks < Request::Builder::RequestConfig::Base
      [:before_validate].each do |name|
        define_method name do |&block|
          raise ArgumentError, 'You must provide a block' unless block

          store[name] = block
        end
      end

      def each(&block)
        store.each do |value|
          block.call(value)
        end
      end

      def [] key
        store[key]
      end

      private

      def store
        @store ||= HashWithIndifferentAccess.new
      end
    end
  end
end
