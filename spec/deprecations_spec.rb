require 'spec_helper'

module DeprecationsSamples # samples how to use

  # mixin with some methods for demonstration
  module MethodSamples
    def foo(*parameters)
      block_given? ? yield(parameters) : {foo: parameters}
    end

    def alt
      :nop
    end
  end

  # mixin with initializer method for demonstration
  module InitializerSample
    attr_reader :parameters
    def initialize(*parameters)
      @parameters = block_given? ? yield(parameters) : {foo: parameters}
    end
  end

  # here we go:

  # method Sample1#foo is deprecated
  class Sample1
    include MethodSamples
    deprecated :foo
  end

  # method Sample2#foo is deprecated, Sample2#alt should be used
  class Sample2
    include MethodSamples
    deprecated :foo, :alt
  end

  # method Sample3#foo is deprecated and will be outdated in next version, Sample3#alt should be used
  class Sample3
    include MethodSamples
    deprecated :foo, :alt, 'next version'
  end

  # class method Sample4::foo is deprecated
  class Sample4
    extend MethodSamples
    deprecated :foo
  end

  # class method Sample5::foo is deprecated, Sample5::alt should be used
  class Sample5
    extend MethodSamples
    deprecated :foo, :alt
  end

  # class method Sample6::foo is deprecated and will be outdated in next version, Sample6::alt should be used
  class Sample6
    extend MethodSamples
    deprecated :foo, :alt, 'next version'
  end

  # class Sample7 is deprecated
  class Sample7
    deprecated!
    include InitializerSample
  end

  # class Sample8 is deprecated, class Sample1 should be used
  class Sample8
    deprecated! Sample1
    include InitializerSample
  end

  # class Sample9 is deprecated and will be outdated in version 2.0.0, class Sample1 should be used
  class Sample9
    deprecated! Sample1, 'in 2.0.0'
    include InitializerSample
  end

end

RSpec.shared_examples_for 'a transparent deprecated method' do
  it 'forwards all parameter and returns the original method`s result' do
    allow(Kernel).to receive(:warn)
    expect(sample.foo(:arg1, :arg2, 42)).to eq(foo: [:arg1, :arg2, 42])
  end

  it 'forwards a given Proc to the original method' do
    allow(Kernel).to receive(:warn)
    expect(sample.foo(:arg1, 'test', 42){ |p| {via_block: p} }).to eq(via_block: [:arg1, 'test', 42])
  end
end

RSpec.shared_examples_for 'a deprecated method (warnings enabled)' do
  it_should_behave_like 'a transparent deprecated method'

  it 'warns about the deprecation' do
    expect(Kernel).to receive(:warn).once.with(/\bDeprecationsSamples::Sample\d[\.#]foo\b.*\bdeprecated\b/)
    sample.foo
  end

  it 'points to the calling line' do
    expect(Kernel).to receive(:warn).with(/#{__FILE__}:#{__LINE__ + 1}/)
    sample.foo
  end

end

RSpec.shared_examples_for 'a deprecated method (should throw)' do
  it 'raises an DeprecationError' do
    expect{ sample.foo }.to raise_error(DeprecationError, /\bDeprecationsSamples::Sample\d[\.#]foo\b.*\bdeprecated\b/)
  end

  it 'has a helpful backtrace' do
    backtrace = nil
    begin
      sample.foo
    rescue DeprecationError => err
      backtrace = err.backtrace
    end
    expect(backtrace.first).to match(/#{__FILE__}:#{__LINE__ - 4}/)
  end
end

RSpec.shared_examples_for 'a transparent deprecated class' do
  it 'calls the original initializer with all parameters' do
    allow(Kernel).to receive(:warn)
    instance = sample.new(:arg1, :arg2, 42)
    expect(instance.parameters).to eq(foo: [:arg1, :arg2, 42])
  end

  it 'forwards a given Proc to the original initializer' do
    allow(Kernel).to receive(:warn)
    instance = sample.new(:arg1, 'test', 42){ |p| {via_block: p} }
    expect(instance.parameters).to eq(via_block: [:arg1, 'test', 42])
  end
end

RSpec.shared_examples_for 'a deprecated class (warnings enabled)' do
  it_should_behave_like 'a transparent deprecated class'

  it 'warns about the deprecation' do
    expect(Kernel).to receive(:warn).once.with(/\b#{sample}\b.*\bdeprecated\b/)
    sample.new
  end

  it 'points to the calling line' do
    expect(Kernel).to receive(:warn).with(/#{__FILE__}:#{__LINE__ + 1}/)
    sample.new
  end
end

RSpec.shared_examples_for 'a deprecated class (should throw)' do
  it 'raises an DeprecationError' do
    expect{ sample.new }.to raise_error(DeprecationError, /\bDeprecationsSamples::Sample\d\b.*\bdeprecated\b/)
  end

  it 'has a helpful backtrace' do
    backtrace = nil
    begin
      sample.new
    rescue DeprecationError => err
      backtrace = err.backtrace
    end
    expect(backtrace.first).to match(/#{__FILE__}:#{__LINE__ - 4}/)
  end
end

RSpec.describe Deprecations do
  context 'when configured as silent' do
    before :all do
      Deprecations.configuration.behavior = :silence
    end

    context 'when an instance method is marked as deprecated' do
      let(:sample){ DeprecationsSamples::Sample1.new }
      it_should_behave_like 'a transparent deprecated method'
    end

    context 'when a class method is marked as deprecated' do
      let(:sample){ DeprecationsSamples::Sample4 }
      it_should_behave_like 'a transparent deprecated method'
    end

    context 'when a class is marked as deprecated' do
      let(:sample){ DeprecationsSamples::Sample7 }
      it_should_behave_like 'a transparent deprecated class'
    end
  end

  context 'when configured to warn' do
    before :all do
      Deprecations.configuration.behavior = :warn
    end

    context 'when an instance method is marked as deprecated' do
      let(:sample){ DeprecationsSamples::Sample1.new }

      it_should_behave_like 'a deprecated method (warnings enabled)'

      context 'when an optional alternative method is given' do
        let(:sample){ DeprecationsSamples::Sample2.new }

        it_should_behave_like 'a deprecated method (warnings enabled)'

        it 'suggests the alternative method' do
          expect(Kernel).to receive(:warn).with(/DeprecationsSamples::Sample2#alt.*instead/)
          sample.foo
        end
      end

      context 'when an optional comment is given' do
        let(:sample){ DeprecationsSamples::Sample3.new }

        it_should_behave_like 'a deprecated method (warnings enabled)'

        it 'informs about when it will become outdated' do
          expect(Kernel).to receive(:warn).with(/outdated next version/)
          sample.foo
        end
      end
    end

    context 'when a class method is marked as deprecated' do
      let(:sample){ DeprecationsSamples::Sample4 }

      it_should_behave_like 'a deprecated method (warnings enabled)'

      context 'when an optional alternative method is given' do
        let(:sample){ DeprecationsSamples::Sample5 }

        it_should_behave_like 'a deprecated method (warnings enabled)'

        it 'suggests the alternative method' do
          expect(Kernel).to receive(:warn).with(/\bDeprecationsSamples::Sample5\.alt\b.*\binstead\b/)
          sample.foo
        end
      end

      context 'when an optional comment is given' do
        let(:sample){ DeprecationsSamples::Sample6 }

        it_should_behave_like 'a deprecated method (warnings enabled)'

        it 'informs about when it will become outdated' do
          expect(Kernel).to receive(:warn).with(/outdated next version/)
          sample.foo
        end
      end

    end

    context 'when a class is marked as deprecated' do
      let(:sample){ DeprecationsSamples::Sample7 }

      it_should_behave_like 'a deprecated class (warnings enabled)'

      context 'when an optional alternative class is given' do
        let(:sample){ DeprecationsSamples::Sample8 }

        it_should_behave_like 'a deprecated class (warnings enabled)'

        it 'suggests the alternative class' do
          expect(Kernel).to receive(:warn).with(/\bDeprecationsSamples::Sample1\b.*\binstead\b/)
          sample.new
        end
      end

      context 'when an optional comment is given' do
        let(:sample){ DeprecationsSamples::Sample9 }

        it_should_behave_like 'a deprecated class (warnings enabled)'

        it 'informs about when it will become outdated' do
          expect(Kernel).to receive(:warn).with(/outdated in 2.0.0/)
          sample.new
        end
      end
    end

    context 'error cases' do

      context 'when the method to mark as deprecated does not exist' do
        it 'raises a NameError' do
          expect do
            Class.new do
              deprecated :does_not_exist
            end
          end.to raise_error(NameError, /undefined method.*does_not_exist/)
        end
      end

      context 'when the alternative method does not exist' do
        it 'raises a NameError' do
          expect do
            Class.new do
              def foo; end
              deprecated :foo, :not_existing_alternative
            end
          end.to raise_error(NameError, /undefined method.*not_existing_alternative/)
        end
      end

    end
  end

  context 'when configured to raise' do
    before :all do
      Deprecations.configuration.behavior = :raise
    end

    context 'when an instance method is marked as deprecated' do
      let(:sample){ DeprecationsSamples::Sample1.new }

      it_should_behave_like 'a deprecated method (should throw)'

      context 'when an optional alternative method is given' do
        let(:sample){ DeprecationsSamples::Sample2.new }

        it_should_behave_like 'a deprecated method (should throw)'

        it 'suggests the alternative method' do
          expect{ sample.foo }.to raise_error(DeprecationError, /DeprecationsSamples::Sample2#alt.*instead/)
        end
      end
    end

    context 'when a class method is marked as deprecated' do
      let(:sample){ DeprecationsSamples::Sample7 }

      it_should_behave_like 'a deprecated class (should throw)'

      context 'when an optional alternative class is given' do
        let(:sample){ DeprecationsSamples::Sample8 }

        it_should_behave_like 'a deprecated class (should throw)'

        it 'suggests the alternative class' do
          expect{ sample.new }.to raise_error(DeprecationError, /\bDeprecationsSamples::Sample8\b.*\binstead\b/)
        end
      end
    end
  end
end