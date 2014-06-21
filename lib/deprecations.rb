
module Deprecations
  autoload(:VERSION, "#{__FILE__[/.*(?=\..+$)/]}/version")
  require_relative 'deprecations/configuration'
  require_relative 'deprecations/extension'

  class << self

    def call(context, alternative, outdated)
      case configuration.behavior
      when :warn
        warn(context, alternative, outdated)
      when :throw
        throw!(context, alternative)
      end
      self
    end

    private

    def throw!(context, alternative)
      msg = "`#{context}` is deprecated"
      alternative and msg << " - use #{alternative} instead"
      ex = DeprecationError.new(msg)
      ex.set_backtrace(caller(3))
      raise(ex)
    end

    def warn(context, alternative, outdated)
      location = ::Kernel.caller_locations(3,1).last and location = "#{location.path}:#{location.lineno}: "
      msg = "#{location}[DEPRECATION] `#{context}` is deprecated"
      msg << (outdated ? " and will be outdated #{outdated}." : '.')
      alternative and msg << " Please use `#{alternative}` instead."
      ::Kernel.warn(msg)
    end

  end
end
