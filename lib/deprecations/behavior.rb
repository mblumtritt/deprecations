# frozen_string_literal: true

module Deprecations
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

    private

    def as_behavior(arg)
      return arg if defined?(arg.call)
      BEHAVIOR.fetch(arg) do
        raise(
          ArgumentError,
          'invalid parameter - behavior has to be ' \
            "#{valid_behaviors} or need to respond to `#call`"
        )
      end
    end

    def valid_behaviors
      BEHAVIOR.keys.map(&:inspect).join(' | ')
    end

    module Raise
      def self.call(subject, alternative, _outdated)
        raise(
          Error
            .new(
              "`#{subject}` is deprecated#{
                " - use #{alternative} instead" if alternative
              }"
            )
            .tap { |error| error.set_backtrace(caller(3)) }
        )
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
  end
end
