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
        def config(conf=nil)
          @config ||= conf.deep_dup || RequestConfig.new
        end

        def configure(conf = nil, &block)
          config(conf)

          config.instance_eval(&block) if block
        end
      end
    end
  end
end
