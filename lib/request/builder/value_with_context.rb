module Request
  module Builder
    module ValueWithContext
      def value_with_context(obj)
        return obj unless obj.is_a?(Proc)

        case obj.arity
        when 1, -1, -2 then instance_exec(@context, &obj)
        else instance_exec(&obj)
        end
      end
    end
  end
end
