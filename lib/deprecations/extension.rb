
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

      def __define_deprecated(opts)
        alias_name = "__deprecated__#{opts[:name]}__"
        private_method_defined?(alias_name) and raise(
          ScriptError, "method is already deprecated - #{opts[:decorated]}"
        )
        alias_method(alias_name, opts[:name])
        private(alias_name)
        define_method(opts[:name]) do |*a, &b|
          Deprecations.call(opts[:decorated], opts[:alternative], opts[:outdated])
          send(alias_name, *a, &b)
        end
        send(opts[:scope], opts[:name])
        opts[:name]
      end
    end

    module ClassMethods
      include Helper
      private

      def deprecated(method_name, alternative_method_name = nil, outdated = nil)
        method_scope = __method_scope(method_name) or __not_found!(method_name)
        __define_deprecated(
          name: method_name,
          scope: method_scope,
          decorated: "#{self.inspect[8..-2]}.#{method_name}",
          alternative: __decorated(alternative_method_name),
          outdated: outdated
        )
      ensure
        $@ and $@.delete_if{ |s| s.index(__FILE__) }
      end

      def __decorated(name)
        name or return nil
        __method_scope(name) and return "#{self.inspect[8..-2]}.#{name}"
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
          name: :new,
          scope: :public,
          decorated: name,
          alternative: alternative ? "#{alternative}" : nil,
          outdated: outdated
        )
      end

      def deprecated(method_name, alternative_method_name = nil, outdated = nil)
        method_scope = __method_scope(method_name) and return __define_deprecated(
          name: method_name,
          scope: method_scope,
          decorated: "#{name}##{method_name}",
          alternative: __decorated(alternative_method_name),
          outdated: outdated
        )
        singleton_class.send(:deprecated, method_name, alternative_method_name, outdated)
      ensure
        $@ and $@.delete_if{ |s| s.index(__FILE__) }
      end

      def __decorated(name)
        name or return nil
        __method_scope(name) ? "#{self.name}##{name}" : singleton_class.send(:__decorated, name)
      end
    end
  end

  infect(Module)
  TOPLEVEL_BINDING.eval('DeprecationError = Class.new(ScriptError)')
end
