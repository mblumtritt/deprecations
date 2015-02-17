module Deprecations
  autoload(:VERSION, "#{__FILE__[/.*(?=\..+$)/]}/version")
  require_relative 'deprecations/extension'
  require_relative 'deprecations/behavior'

  def self.call(subject, alternative, outdated)
    @behavior.call(subject, alternative, outdated)
    self
  end

  self.behavior = :warn
end

DeprecationError = Class.new(ScriptError)
