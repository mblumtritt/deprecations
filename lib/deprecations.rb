# frozen_string_literal: true

module Deprecations
  Error = Class.new(ScriptError)

  class << self
    def behavior = BEHAVIOR.key(@behavior) || @behavior

    def behavior=(value)
      @behavior = as_behavior(value)
    end

    def with_behavior(behavior)
      current_behavior = @behavior
      @behavior = as_behavior(behavior)
      raise(ArgumentError, 'block expected') unless block_given?
      yield
    ensure
      @behavior = current_behavior
    end

    alias set_behavior with_behavior

    def call(subject, alternative, outdated)
      @behavior.call(subject, alternative, outdated)
      self
    end

    private

    def as_behavior(arg)
      return arg if defined?(arg.call)
      BEHAVIOR.fetch(arg) do
        raise(
          ArgumentError,
          "invalid parameter - behavior has to be #{
            BEHAVIOR.keys.map(&:inspect).join(' | ')
          } or need to respond to `#call`"
        )
      end
    end

    def name_error(exc, raise_again = true)
      exc.set_backtrace(
        exc.backtrace_locations.drop_while { _1.path.start_with?(__FILE__) }
      )
      raise if raise_again
    end

    module Raise
      def self.call(subject, alternative, _outdated)
        error =
          Error.new(
            "`#{subject}` is deprecated#{
              " - use #{alternative} instead" if alternative
            }"
          )
        error.set_backtrace(caller(3))
        raise(error)
      end
    end

    module WarnMessage
      def message(subject, alternative, outdated)
        "`#{subject}` is deprecated#{
          outdated ? " and will be outdated #{outdated}." : '.'
        }#{" Please use `#{alternative}` instead." if alternative}"
      end
    end

    module Warn
      extend WarnMessage
      def self.call(*args) = ::Kernel.warn(message(*args), uplevel: 3)
    end

    module Deprecated
      extend WarnMessage
      def self.call(*args)
        ::Kernel.warn(message(*args), uplevel: 3, category: :deprecated)
      end
    end

    BEHAVIOR = {
      silence: proc {},
      raise: Raise,
      warn: Warn,
      deprecated: Deprecated
    }.freeze

    module ClassMethods
      private

      def deprecated(name, alt = nil, outdated = nil)
        alias_name = "__deprecated__singleton_method__#{name}__"
        return if private_method_defined?(alias_name)
        begin
          alias_method(alias_name, name)
        rescue NameError => e
          ::Deprecations.__send__(:name_error, e)
        end
        private(alias_name)
        if alt.is_a?(Symbol)
          begin
            alt = instance_method(alt)
          rescue NameError => e
            ::Deprecations.__send__(:name_error, e)
          end
        end
        define_method(name) do |*args, **kw_args, &b|
          ::Deprecations.call(
            "#{self}.#{::Kernel.__method__}",
            (alt.is_a?(UnboundMethod) ? "#{self}.#{alt.name}" : alt),
            outdated
          )
          __send__(alias_name, *args, **kw_args, &b)
        end
      end
    end

    module InstanceMethods
      private

      def deprecated(name, alt = nil, outdated = nil)
        alias_name = "__deprecated__instance_method__#{name}__"
        return if private_method_defined?(alias_name)
        begin
          alias_method(alias_name, name)
        rescue NameError => e
          ::Deprecations.__send__(:name_error, e, false)
          return singleton_class.__send__(:deprecated, name, alt, outdated)
        end
        private(alias_name)
        if alt.is_a?(Symbol)
          begin
            alt = instance_method(alt)
          rescue NameError => e
            ::Deprecations.__send__(:name_error, e)
          end
        end
        define_method(name) do |*args, **kw_args, &b|
          pref =
            if defined?(self.class.name)
              self.class.name
            else
              ::Kernel.instance_method(:class).bind(self).call
            end
          ::Deprecations.call(
            "#{pref}##{::Kernel.__method__}",
            (alt.is_a?(UnboundMethod) ? "#{pref}##{alt.name}" : alt),
            outdated
          )
          __send__(alias_name, *args, **kw_args, &b)
        end
      end

      def deprecated!(alternative = nil, outdated = nil)
        org = method(:new)
        define_singleton_method(:new) do |*args, **kw_args, &b|
          ::Deprecations.call(name, alternative, outdated)
          org.call(*args, **kw_args, &b)
        end
      end
    end

    Module.extend(ClassMethods)
    Module.include(InstanceMethods)
  end

  self.behavior = :warn
end
