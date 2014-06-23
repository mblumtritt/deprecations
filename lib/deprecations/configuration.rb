
module Deprecations
  class << self

    def configure
      yield(@@cfg = Cfg.new)
    end

    def configuration
      @@cfg
    end

    BEHAVIORS = [:warn, :raise, :silence].freeze

    private

    class Cfg < BasicObject
      attr_reader :behavior

      def initialize
        @behavior = :warn
      end

      def behavior=(how)
        BEHAVIORS.include?(how) and return @behavior = how
        ::Kernel.raise(
          ::ArgumentError, "invalid parameter `#{how}` - have to be #{BEHAVIORS.map(&:inspect).join(' | ')}"
        )        
      end

    end

    @@cfg = Cfg.new
  end
end
