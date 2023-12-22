# frozen_string_literal: true

module Deprecations
  private_class_method def self.infect(mod)
    mod.extend(ClassMethods)
    mod.__send__(:include, InstanceMethods)
  end

  module ClassMethods
    private

    def deprecated(method_name, alternative = nil, outdated = nil)
      alias_name = "__deprecated__singleton_method__#{method_name}__"
      return if private_method_defined?(alias_name)
      alias_method(alias_name, method_name)
      private(alias_name)
      alternative = instance_method(alternative) if alternative.is_a?(Symbol)
      define_method(method_name) do |*args, **kw_args, &b|
        Deprecations.call(
          "#{self}.#{::Kernel.__method__}",
          if alternative.is_a?(UnboundMethod)
            "#{self}.#{alternative.name}"
          else
            alternative
          end,
          outdated
        )
        __send__(alias_name, *args, **kw_args, &b)
      end
    end
  end

  module InstanceMethods
    private

    def deprecated(method_name, alternative = nil, outdated = nil)
      alias_name = "__deprecated__instance_method__#{method_name}__"
      return if private_method_defined?(alias_name)
      alias_method(alias_name, method_name)
      private(alias_name)
      alternative = instance_method(alternative) if alternative.is_a?(Symbol)
      define_method(method_name) do |*args, **kw_args, &b|
        pref =
          if defined?(self.class.name)
            self.class.name
          else
            Kernel.instance_method(:class).bind(self).call
          end
        Deprecations.call(
          "#{pref}##{::Kernel.__method__}",
          if alternative.is_a?(UnboundMethod)
            "#{pref}##{alternative.name}"
          else
            alternative
          end,
          outdated
        )
        __send__(alias_name, *args, **kw_args, &b)
      end
    rescue NameError
      raise if private_method_defined?(alias_name)
      singleton_class.__send__(:deprecated, method_name, alternative, outdated)
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

  infect(Module)
end
