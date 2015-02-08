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
        define_method(method.name) do |*a, &b|
          decorated = Class === self ? "#{self}." : "#{self.class}#"
          Deprecations.call(
            "#{decorated}#{__method__}",
            UnboundMethod === alternative ? "#{decorated}#{alternative.name}" : alternative,
            outdated
          )
          method.bind(self).call(*a, &b)
        end
      end

      def __method_not_found!(method_name)
        raise(NameError, "undefined method `#{method_name}` for class `#{self}`")
      end

    end

    module ClassMethods
      private
      include Helper

      def deprecated(method_name, alternative = nil, outdated = nil)
        m = __method(method_name) or __method_not_found!(method_name)
        a = Symbol === alternative ? (__method(alternative) or __method_not_found!(alternative)) : alternative
        __method_deprecated!(m, a, outdated)
      end
    end

    module InstanceMethods
      private
      include Helper

      def deprecated(method_name, alternative = nil, outdated = nil)
        m = __method(method_name) or return singleton_class.send(:deprecated, method_name, alternative, outdated)
        a = Symbol === alternative ? (__method(alternative) or __method_not_found!(alternative)) : alternative
        __method_deprecated!(m, a, outdated)
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
