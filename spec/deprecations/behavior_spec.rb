require 'spec_helper'

RSpec.describe Deprecations do
  context 'behavior' do

    it 'is possible to configure the behavior with a pre-defined value' do
      %i(silence raise warn).each do |behavior|
        Deprecations.behavior = behavior
        expect(Deprecations.behavior).to be(behavior)
      end
    end

    it 'is possible to configure a custom behavior' do
      custom = proc do |*args|
        FantasticLogger.log(*args)
      end
      Deprecations.behavior = custom
      expect(Deprecations.behavior).to be(custom)
    end

    context 'standard behavior :silence' do
      before do
        Deprecations.behavior = :silence
      end

      it 'does simply nothing' do
        expect(subject.call(*%w(should be silent))).to be(subject)
      end
    end

    context 'standard behavior :warn' do
      before do
        Deprecations.behavior = :warn
      end
      after do
        Deprecations.call('Bad#method', 'Bad#alternative', 'after next version')
      end

      it 'warns about the deprecation' do
        expect(Kernel).to receive(:warn).once.with(/.*/, uplevel: 3)
      end

      it 'points to the deprecated method' do
        expect(Kernel).to receive(:warn).once.with(/Bad#method.*deprecated/, uplevel: 3)
      end

      it 'suggests the alternative method' do
        expect(Kernel).to receive(:warn).once.with(/Bad#alternative.*instead/, uplevel: 3)
      end

      it 'contains information about when it will not longer supported' do
        expect(Kernel).to receive(:warn).once.with(/outdated after next version/, uplevel: 3)
      end
    end

    context 'standard behavior :raise' do
      before do
        Deprecations.behavior = :raise
      end
      subject{ Deprecations.call('Bad#method', 'Bad#alternative', 'after next version') }

      it 'raises a Deprecations::Error' do
        expect{ subject }.to raise_error(Deprecations::Error)
      end

      it 'points to the deprecated method' do
        expect{ subject }.to raise_error(Deprecations::Error, /Bad#method.*deprecated/)
      end

      it 'suggests the alternative method' do
        expect{ subject }.to raise_error(Deprecations::Error, /Bad#alternative.*instead/)
      end
    end

    context 'change behavior temporary' do
      let(:sample_class) do
        Class.new(BasicObject) do
          deprecated!
        end
      end

      before do
        Deprecations.behavior = :raise
      end

      after do
        Deprecations.with_behavior(:warn) do
          sample_class.new.__id__
        end
      end

      it 'is possible to temporary use a different behavior' do
        expect(Kernel).to receive(:warn).once
      end
    end
  end
end
