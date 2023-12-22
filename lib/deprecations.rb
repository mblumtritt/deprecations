# frozen_string_literal: true

module Deprecations
  require_relative 'deprecations/behavior'
  require_relative 'deprecations/extension'
  require_relative 'deprecations/version'

  Error = Class.new(ScriptError)

  def self.call(subject, alternative, outdated)
    @behavior.call(subject, alternative, outdated)
    self
  end

  self.behavior = :warn
end

DeprecationError = Deprecations::Error
