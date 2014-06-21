require 'spec_helper'

module DeprecationsSamples

  module MethodSamples
    def foo(*parameters)
      block_given? ? yield(parameters) : {foo: parameters}
    end

    def alt
      :nop
    end
  end

  module InitializerSample
    attr_reader :parameters
    def initialize(*parameters)
      @parameters = block_given? ? yield(parameters) : {foo: parameters}
    end
  end

  class Sample1
    include MethodSamples
    deprecated :foo
  end

  class Sample2
    include MethodSamples
    deprecated :foo, :alt
  end

  class Sample3
    include MethodSamples
    deprecated :foo, :alt, 'next version'
  end

  class Sample4
    extend MethodSamples
    deprecated :foo
  end

  class Sample5
    extend MethodSamples
    deprecated :foo, :alt
  end

  class Sample6
    extend MethodSamples
    deprecated :foo, :alt, 'next version'
  end

  class Sample7
    include InitializerSample
    deprecated!
  end

  class Sample8
    include InitializerSample
    deprecated! Sample1
  end

  class Sample9
    include InitializerSample
    deprecated! Sample1, 'in 2.0.0'
  end

end

RSpec.shared_examples_for 'a deprecated method' do
  it 'warns about the deprecation' do
    expect(Kernel).to receive(:warn).once.with(/\bDeprecationsSamples::Sample\d[\.#]foo\b.*\bdeprecated\b/)
    sample.foo
  end

  it 'points to the calling line' do
    expect(Kernel).to receive(:warn).with(/#{__FILE__}:#{__LINE__ + 1}/)
    sample.foo
  end

  it 'returns the original method`s result' do
    allow(Kernel).to receive(:warn)
    expect(sample.foo(:arg1, :arg2, 42)).to eq(foo: [:arg1, :arg2, 42])
  end

  it 'returns calls given Proc correctly' do
    allow(Kernel).to receive(:warn)
    expect(sample.foo(:arg1, 'test', 42){ |p| {via_block: p} }).to eq(via_block: [:arg1, 'test', 42])
  end
end

RSpec.shared_examples_for 'a deprecated class' do
  it 'warns about the deprecation' do
    expect(Kernel).to receive(:warn).once.with(/\b#{sample}\b.*\bdeprecated\b/)
    sample.new
  end

  it 'points to the calling line' do
    expect(Kernel).to receive(:warn).with(/#{__FILE__}:#{__LINE__ + 1}/)
    sample.new
  end

  it 'calls the original initializer' do
    allow(Kernel).to receive(:warn)
    instance = sample.new(:arg1, :arg2, 42)
    expect(instance.parameters).to eq(foo: [:arg1, :arg2, 42])
  end

  it 'returns calls given Proc correctly' do
    allow(Kernel).to receive(:warn)
    instance = sample.new(:arg1, 'test', 42){ |p| {via_block: p} }
    expect(instance.parameters).to eq(via_block: [:arg1, 'test', 42])
  end
end

RSpec.describe Deprecations do
  context 'when an instance method is marked as deprecated' do
    let(:sample){ DeprecationsSamples::Sample1.new }

    it_should_behave_like 'a deprecated method'

    context 'when an optional alternative method is given' do
      let(:sample){ DeprecationsSamples::Sample2.new }

      it_should_behave_like 'a deprecated method'

      it 'suggests the alternative method' do
        expect(Kernel).to receive(:warn).with(/DeprecationsSamples::Sample2#alt.*instead/)
        sample.foo
      end
    end

    context 'when an optional comment is given' do
      let(:sample){ DeprecationsSamples::Sample3.new }

      it_should_behave_like 'a deprecated method'

      it 'informs about when it will become outdated' do
        expect(Kernel).to receive(:warn).with(/outdated next version/)
        sample.foo
      end
    end
  end

  context 'when a class method is marked as deprecated' do
    let(:sample){ DeprecationsSamples::Sample4 }

    it_should_behave_like 'a deprecated method'

    context 'when an optional alternative method is given' do
      let(:sample){ DeprecationsSamples::Sample5 }

      it_should_behave_like 'a deprecated method'

      it 'suggests the alternative method' do
        expect(Kernel).to receive(:warn).with(/\bDeprecationsSamples::Sample5\.alt\b.*\binstead\b/)
        sample.foo
      end
    end

    context 'when an optional comment is given' do
      let(:sample){ DeprecationsSamples::Sample6 }

      it_should_behave_like 'a deprecated method'

      it 'informs about when it will become outdated' do
        expect(Kernel).to receive(:warn).with(/outdated next version/)
        sample.foo
      end
    end

  end

  context 'when a class is marked as deprecated' do
    let(:sample){ DeprecationsSamples::Sample7 }

    it_should_behave_like 'a deprecated class'

    context 'when an optional alternative class is given' do
      let(:sample){ DeprecationsSamples::Sample8 }

      it_should_behave_like 'a deprecated class'

      it 'suggests the alternative class' do
        expect(Kernel).to receive(:warn).with(/\bDeprecationsSamples::Sample1\b.*\binstead\b/)
        sample.new
      end
    end

    context 'when an optional comment is given' do
      let(:sample){ DeprecationsSamples::Sample9 }

      it_should_behave_like 'a deprecated class'

      it 'informs about when it will become outdated' do
        expect(Kernel).to receive(:warn).with(/outdated in 2.0.0/)
        sample.new
      end
    end
  end

  context 'error cases' do

    context 'when the method to mark as deprecated does not exist' do
      it 'raises an error' do
        expect do
          Class.new do
            deprecated :does_not_exist
          end
        end.to raise_error(NameError, /undefined method.*does_not_exist/)
      end
    end

    context 'when the alternative method does not exist' do
      it 'raises an error' do
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
