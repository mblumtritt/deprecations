module Deprecations
  class << self
    def behavior
      BEHAVIOR.key(@behavior) || @behavior
    end

    def behavior=(behavior)
      @behavior = as_behavior(behavior)
    end

    def with_behavior(behavior)
      behavior = as_behavior(behavior)
      raise(ArgumentError, 'block expected') unless block_given?
      current_behavior = @behavior
      begin
        @behavior = behavior
        yield
      ensure
        @behavior = current_behavior
      end
    end

    alias set_behavior with_behavior

    private

    def as_behavior(arg)
      return arg if defined?(arg.call)
      BEHAVIOR.fetch(arg) do
        raise(
          ArgumentError,
          'invalid parameter - behavior has to be ' \
            "#{valid_behaviors} or need to respond to `call`"
        )
      end
    end

    def valid_behaviors
      BEHAVIOR.keys.map(&:inspect).join(' | ')
    end

    module Raise
      def self.call(subject, alternative, _outdated)
        msg = "`#{subject}` is deprecated"
        msg << " - use #{alternative} instead" if alternative
        ex = Error.new(msg)
        ex.set_backtrace(caller(3))
        raise(ex)
      end
    end

    module Warn
      def self.call(subject, alternative, outdated)
        msg = "`#{subject}` is deprecated"
        msg << (outdated ? " and will be outdated #{outdated}." : '.')
        msg << " Please use `#{alternative}` instead." if alternative
        ::Kernel.warn(msg, uplevel: 3)
      end
    end

    BEHAVIOR = {silence: proc {}, raise: Raise, warn: Warn}.freeze
  end
end
