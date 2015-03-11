module Deprecations
  class << self

    def behavior
      BEHAVIOR.key(@behavior) || @behavior
    end

    def behavior=(behavior)
      @behavior = as_behavior(behavior)
    end

    def set_behavior(behavior)
      behavior = as_behavior(behavior)
      block_given? or raise(ArgumentError, 'block expected')
      current_behavior = @behavior
      begin
        @behavior = behavior
        yield
      ensure
        @behavior = current_behavior
      end
    end

    private

    def as_behavior(arg)
      defined?(arg.call) ? arg : BEHAVIOR.fetch(arg) do
        raise(ArgumentError, "invalid parameter - behavior has to be #{valid_behavior} or need to respond to `call`")
      end
    end

    def valid_behavior
      BEHAVIOR.keys.map(&:inspect).join(' | ')
    end

    module Raise
      def self.call(subject, alternative, _outdated)
        msg = "`#{subject}` is deprecated"
        alternative and msg << " - use #{alternative} instead"
        ex = DeprecationError.new(msg)
        ex.set_backtrace(caller(4))
        raise(ex)
      end
    end

    module Warn
      def self.call(subject, alternative, outdated)
        location = caller_locations(4, 1).last and location = "#{location.path}:#{location.lineno}: "
        msg = "#{location}[DEPRECATION] `#{subject}` is deprecated"
        msg << (outdated ? " and will be outdated #{outdated}." : '.')
        alternative and msg << " Please use `#{alternative}` instead."
        ::Kernel.warn(msg)
      end
    end

    BEHAVIOR = {silence: ->(*){}, raise: Raise, warn: Warn}

  end
end
