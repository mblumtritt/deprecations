# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Deprecations do
  context 'behavior' do
    it 'is possible to configure the behavior with a pre-defined value' do
      %i[silence raise warn].each do |behavior|
        Deprecations.behavior = behavior
        expect(Deprecations.behavior).to be(behavior)
      end
    end

    it 'is possible to configure a custom behavior' do
      custom = proc { |*args| FantasticLogger.log(*args) }
      Deprecations.behavior = custom

      expect(Deprecations.behavior).to be(custom)
    end

    context 'when behavior is :silence' do
      before { Deprecations.behavior = :silence }

      it 'does simply nothing' do
        expect(subject.call(*%w[should be silent])).to be(subject)
      end
    end

    context 'when behavior is :warn' do
      before { Deprecations.behavior = :warn }
      after do
        Deprecations.call('Bad#method', 'Bad#alternative', 'after next version')
      end

      it 'warns about the deprecation' do
        expect(Kernel).to receive(:warn).once.with(/.*/, uplevel: 3)
      end

      it 'points to the deprecated method' do
        expect(Kernel).to receive(:warn).once.with(
          /Bad#method.*deprecated/,
          uplevel: 3
        )
      end

      it 'suggests the alternative method' do
        expect(Kernel).to receive(:warn).once.with(
          /Bad#alternative.*instead/,
          uplevel: 3
        )
      end

      it 'contains information about when it will not longer supported' do
        expect(Kernel).to receive(:warn).once.with(
          /outdated after next version/,
          uplevel: 3
        )
      end
    end

    context 'when behavior is :raise' do
      subject do
        Deprecations.call('Bad#method', 'Bad#alternative', 'after next version')
      end

      before { Deprecations.behavior = :raise }

      it 'raises a Deprecations::Error' do
        expect { subject }.to raise_error(Deprecations::Error)
      end

      it 'points to the deprecated method' do
        expect { subject }.to raise_error(
          Deprecations::Error,
          /Bad#method.*deprecated/
        )
      end

      it 'suggests the alternative method' do
        expect { subject }.to raise_error(
          Deprecations::Error,
          /Bad#alternative.*instead/
        )
      end
    end

    context 'when behavior is temporary changed' do
      let(:sample_class) { Class.new(BasicObject) { deprecated! } }

      before { Deprecations.behavior = :raise }
      after { Deprecations.with_behavior(:warn) { sample_class.new.__id__ } }

      it 'is possible to temporary use a different behavior' do
        expect(Kernel).to receive(:warn).once
      end
    end
  end
end
