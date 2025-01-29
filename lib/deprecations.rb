# frozen_string_literal: true

module Deprecations
  Error = Class.new(ScriptError)

  class << self
    def behavior
      BEHAVIOR.key(@behavior) || @behavior
    end

    def behavior=(value)
      @behavior = as_behavior(value)
    end

    def with_behavior(behavior)
      behavior = as_behavior(behavior)
      raise(ArgumentError, 'block expected') unless block_given?
      current_behavior = @behavior
      @behavior = behavior
      yield
    ensure
      @behavior = current_behavior if current_behavior
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

    module Warn
      def self.call(subject, alternative, outdated)
        ::Kernel.warn(
          "`#{subject}` is deprecated#{
            outdated ? " and will be outdated #{outdated}." : '.'
          }#{" Please use `#{alternative}` instead." if alternative}",
          uplevel: 3
        )
      end
    end

    BEHAVIOR = { silence: proc {}, raise: Raise, warn: Warn }.freeze

    module ClassMethods
      private

      def deprecated(name, alt = nil, outdated = nil)
        alias_name = "__deprecated__singleton_method__#{name}__"
        return if private_method_defined?(alias_name)
        alias_method(alias_name, name)
        private(alias_name)
        alt = instance_method(alt) if alt.is_a?(Symbol)
        define_method(name) do |*args, **kw_args, &b|
          Deprecations.call(
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
        alias_method(alias_name, name)
        private(alias_name)
        alt = instance_method(alt) if alt.is_a?(Symbol)
        define_method(name) do |*args, **kw_args, &b|
          pref =
            if defined?(self.class.name)
              self.class.name
            else
              Kernel.instance_method(:class).bind(self).call
            end
          Deprecations.call(
            "#{pref}##{::Kernel.__method__}",
            (alt.is_a?(UnboundMethod) ? "#{pref}##{alt.name}" : alt),
            outdated
          )
          __send__(alias_name, *args, **kw_args, &b)
        end
      rescue NameError
        raise if private_method_defined?(alias_name)
        singleton_class.__send__(:deprecated, name, alt, outdated)
      end

      def deprecated!(alternative = nil, outdated = nil)
        org = method(:new)
        define_singleton_method(:new) do |*args, **kw_args, &b|
          Deprecations.call(name, alternative, outdated)
          org.call(*args, **kw_args, &b)
        end
      rescue NameError
        nil
      end
    end

    Module.extend(ClassMethods)
    Module.include(InstanceMethods)
  end

  self.behavior = :warn
end

DeprecationError = Deprecations::Error
