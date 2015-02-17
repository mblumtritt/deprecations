module Deprecations
  class << self
    private

    def infect(mod)
      mod.extend(ClassMethods)
      mod.send(:include, InstanceMethods)
    end

    module Helper
      private
      def __method(method_name)
        instance_method(method_name) rescue nil
      end

      def __method_deprecated!(method, alternative, outdated)
        defining_context = self
        define_method(method.name) do |*a, &b|
          decorated = Class === self ? "#{self}." : "#{defining_context}#"
          Deprecations.call(
            "#{decorated}#{::Kernel.__method__}",
            UnboundMethod === alternative ? "#{decorated}#{alternative.name}" : alternative,
            outdated
          )
          method.bind(self).call(*a, &b)
        end
      end

      def __method_not_found!(method_name)
        raise(NameError, "undefined method `#{method_name}` for class `#{self}`")
      end

      def __method_alternative(alternative)
        Symbol === alternative ? (__method(alternative) or __method_not_found!(alternative)) : alternative
      end
    end

    module ClassMethods
      private
      include Helper

      def deprecated(method_name, alternative = nil, outdated = nil)
        __method_deprecated!(
          (__method(method_name) or __method_not_found!(method_name)),
          __method_alternative(alternative),
          outdated
        )
      end
    end

    module InstanceMethods
      private
      include Helper

      def deprecated(method_name, alternative = nil, outdated = nil)
        m = __method(method_name) or return singleton_class.send(:deprecated, method_name, alternative, outdated)
        __method_deprecated!(m, __method_alternative(alternative), outdated)
      end

      def deprecated!(alternative = nil, outdated = nil)
        m = method(:new)
        define_singleton_method(:new) do |*a, &b|
          Deprecations.call(self, alternative, outdated)
          m.call(*a, &b)
        end
      end
    end

  end

  infect(Module)
end
