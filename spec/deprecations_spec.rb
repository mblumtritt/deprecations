require 'spec_helper'

RSpec.describe Deprecations do
  context 'policy' do
    before do
      Deprecations.behavior = :silence
    end

    context 'parameter forwarding' do

      context 'when an instance method is marked as deprecated' do
        subject do
          Class.new(BasicObject) do
            def foo(*args)
              {foo: args}
            end
            deprecated :foo
          end
        end

        it 'forwards all parameters and returns the original method`s result' do
          result = subject.new.foo(:arg1, :arg2, 42)
          expect(result).to eq(foo: [:arg1, :arg2, 42])
        end
      end

      context 'when a class method is marked as deprecated' do
        subject do
          Class.new(BasicObject) do
            def self.foo(*args)
              {foo: args}
            end
            deprecated :foo
          end
        end

        it 'forwards all parameters and returns the original method`s result' do
          result = subject.foo(:arg1, :arg2, 42)
          expect(result).to eq(foo: [:arg1, :arg2, 42])
        end
      end

      context 'when a class is marked as deprecated' do
        subject do
          Class.new(BasicObject) do
            attr_reader :parameters
            def initialize(*parameters)
              @parameters = parameters
            end
            deprecated!
          end
        end

        it 'forwards all parameters to the initializer and returns the original method`s result' do
          expect(subject.new(:arg1, :arg2, 42).parameters).to eq([:arg1, :arg2, 42])
        end
      end

    end

    context 'block forwarding' do

      context 'when an instance method is marked as deprecated' do
        subject do
          Class.new(BasicObject) do
            def foo(arg)
              yield(arg)
            end
            deprecated :foo
          end
        end

        it 'forwards a given Proc to the original method' do
          result = subject.new.foo(41) do |arg|
            {my_blocks_result: arg + 1}
          end
          expect(result).to eq(my_blocks_result: 42)
        end
      end

      context 'when a class method is marked as deprecated' do
        subject do
          Class.new(BasicObject) do
            def self.foo(arg)
              yield(arg)
            end
            deprecated :foo
          end
        end

        it 'forwards a given Proc to the original method' do
          result = subject.foo(665) do |arg|
            {my_blocks_result: arg + 1}
          end
          expect(result).to eq(my_blocks_result: 666)
        end
      end

      context 'when a class is marked as deprecated' do
        subject do
          Class.new(BasicObject) do
            attr_reader :value
            def initialize(arg)
              @value = yield(arg)
            end
            deprecated!
          end
        end

        it 'forwards a given Proc to the initializer' do
          instance = subject.new(41) do |arg|
            {my_blocks_result: arg + 1}
          end
          expect(instance.value).to eq(my_blocks_result: 42)
        end
      end

    end

  end

  context 'handling' do

    context 'when a method is marked as deprecated' do

      context 'when an alternative method and a comment are present ' do
        subject do
          Class.new(BasicObject) do
            def foo
            end
            def bar
            end
            deprecated :foo, :bar, 'next version'
          end
        end

        after do
          subject.new.foo
        end

        it 'calls the handler with correct subject' do
          expect(Deprecations).to receive(:call).once.with("#{subject}#foo", anything, anything)
        end
        it 'calls the handler with correct alternative method' do
          expect(Deprecations).to receive(:call).once.with(anything, "#{subject}#bar", anything)
        end
        it 'calls the handler with a comment' do
          expect(Deprecations).to receive(:call).once.with(anything, anything, 'next version')
        end
      end

      context 'when no alternative method and no comment are present' do
        subject do
          Class.new(BasicObject) do
            def bar
            end
            deprecated :bar
          end
        end

        after do
          subject.new.bar
        end

        it 'calls handler without an alternative method' do
          expect(Deprecations).to receive(:call).once.with(anything, nil, anything)
        end
        it 'calls handler without a comment' do
          expect(Deprecations).to receive(:call).once.with(anything, anything, nil)
        end
      end

    end

    context 'when a class is anonymous defined' do
      module Samples
        AnonymousDefined = Class.new(::BasicObject) do
          def clean; end
          def clear; end
          deprecated :clean, :clear

          def self.create; end
          def self.make; end
          deprecated :create, :make
        end
      end

      it 'uses correct decorated instance method names' do
        expect(Deprecations).to receive(:call).once.with(
          'Samples::AnonymousDefined#clean',
          'Samples::AnonymousDefined#clear',
          nil
        )
        Samples::AnonymousDefined.new.clean
      end

      it 'uses correct decorated singleton method names' do
        expect(Deprecations).to receive(:call).once.with(
          'Samples::AnonymousDefined.create',
          'Samples::AnonymousDefined.make',
          nil
        )
        Samples::AnonymousDefined.create
      end
    end

    context 'when a sub-class is used' do
      module Samples
        class Parent < ::BasicObject
          def clean; end
          def clear; end
          deprecated :clean, :clear
        end

        class Child < Parent; end
      end

      it 'uses correct decorated method names' do
        expect(Deprecations).to receive(:call).once.with(
          'Samples::Parent#clean',
          'Samples::Parent#clear',
          nil
        )
        Samples::Child.new.clean
      end
    end

  end
end
