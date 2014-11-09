
module Deprecations
  class << self
    private
    def infect(mod)
      mod.extend(ClassMethods)
      mod.send(:include, InstanceMethods)
    end

    module Helper
      private

      def __method_scope(method_name)
        private_method_defined?(method_name) and return :private
        protected_method_defined?(method_name) and return :protected
        public_method_defined?(method_name) and return :public
        nil
      end

      def __define_deprecated(name, decorated_name, scope, alternative, outdated)
        alias_name = __private_alias(name, decorated_name)
        send(scope, name)
        define_method(name) do |*a, &b|
          Deprecations.call(decorated_name, alternative, outdated)
          send(alias_name, *a, &b)
        end
        name
      end

      def __private_alias(name, decorated_name)
        alias_name = "deprecated_#{name}"
        private_method_defined?(alias_name) and raise(ScriptError, "method is already deprecated - #{decorated_name}")
        alias_method(alias_name, name)
        private(alias_name)
        alias_name
      end
    end

    module ClassMethods
      include Helper
      private

      def deprecated(method_name, alternative_method_name = nil, outdated = nil)
        method_scope = __method_scope(method_name) or __not_found!(method_name)
        __define_deprecated(
          method_name,
          ->{"#{self.inspect[8..-2]}.#{method_name}"},
          method_scope,
          __decorated(alternative_method_name),
          outdated
        )
      ensure
        $@ and $@.delete_if{ |s| s.index(__FILE__) }
      end

      def __decorated(name)
        name or return nil
        __method_scope(name) and return ->{"#{self.inspect[8..-2]}.#{name}"}
        Symbol === name and __not_found!(name)
        name
      end

      def __not_found!(name)
        raise(NameError, "undefined method `#{name}` for class `#{self.inspect[8..-2]}`")
      end
    end

    module InstanceMethods
      include Helper
      private

      def deprecated!(alternative = nil, outdated = nil)
        singleton_class.send(
          :__define_deprecated,
          :new,
          ->{self},
          :public,
          alternative ? "#{alternative}" : nil,
          outdated
        )
      end

      def deprecated(method_name, alternative_method_name = nil, outdated = nil)
        method_scope = __method_scope(method_name) and return __define_deprecated(
          method_name,
          ->{"#{self}##{method_name}"},
          method_scope,
          __decorated(alternative_method_name),
          outdated
        )
        singleton_class.send(:deprecated, method_name, alternative_method_name, outdated)
      ensure
        $@ and $@.delete_if{ |s| s.index(__FILE__) }
      end

      def __decorated(name)
        name or return nil
        __method_scope(name) ? ->{"#{self}##{name}"} : singleton_class.send(:__decorated, name)
      end
    end
  end

  infect(Module)
end
