
module Deprecations
  autoload(:VERSION, "#{__FILE__[/.*(?=\..+$)/]}/version")
  require_relative 'deprecations/configuration'
  require_relative 'deprecations/extension'

  class << self

    def call(subject, alternative, outdated)
      case configuration.behavior
      when :warn
        warn(subject, alternative, outdated)
      when :raise
        throw!(subject, alternative)
      end
      self
    end

    private

    def throw!(subject, alternative)
      msg = "`#{subject}` is deprecated"
      alternative and msg << " - use #{alternative} instead"
      ex = DeprecationError.new(msg)
      ex.set_backtrace(caller(3))
      raise(ex)
    end

    def warn(subject, alternative, outdated)
      location = ::Kernel.caller_locations(3,1).last and location = "#{location.path}:#{location.lineno}: "
      msg = "#{location}[DEPRECATION] `#{subject}` is deprecated"
      msg << (outdated ? " and will be outdated #{outdated}." : '.')
      alternative and msg << " Please use `#{alternative}` instead."
      ::Kernel.warn(msg)
    end

  end
end
