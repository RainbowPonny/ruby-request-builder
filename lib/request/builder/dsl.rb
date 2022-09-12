module Request
  module Builder
    module Dsl
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          def config
            @config ||= self.class.config
          end
        end
      end

      module ClassMethods
        def config
          @config ||= RequestConfig.new
        end

        def configure(conf = nil, &block)
          @config = conf.dup if config

          config.instance_eval(&block) if block
        end
      end
    end
  end
end