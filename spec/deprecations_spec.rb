# frozen_string_literal: true

require 'spec_helper'

module Examples
  module FooMod
    def self.bar(*args, **kw_args, &block)
      { __method__ => { args: args, kw_args: kw_args, block: block } }
    end

    def self.alt_bar
      nil
    end

    def self.baz(arg)
      yield(arg) if arg
    end

    deprecated :bar, :alt_bar, 'next version'
    deprecated :baz
  end

  class Foo < BasicObject
    def self.bar(*args, **kw_args, &block)
      { __method__ => { args: args, kw_args: kw_args, block: block } }
    end

    def self.alt_bar
      nil
    end

    def self.baz(arg)
      yield(arg) if arg
    end

    def foo(*args, **kw_args, &block)
      { foo: { args: args, kw_args: kw_args, block: block } }
    end

    def alt_foo
      nil
    end

    def foo_baz(arg)
      yield(arg) if arg
    end

    deprecated :bar, :alt_bar, 'next version'
    deprecated :baz
    deprecated :foo, :alt_foo, 'next version'
    deprecated :foo_baz
  end

  class FooChild < Foo
  end

  class Bar < BasicObject
    deprecated!

    attr_reader :args

    def initialize(*args, **kw_args, &block)
      @args = { initialize: { args: args, kw_args: kw_args, block: block } }
    end
  end
end

RSpec.describe Deprecations do
  let(:block) { proc { 666 } }

  before { Deprecations.behavior = :silence }

  context 'parameter forwarding' do
    it 'forwards parameters of class methods of modules' do
      result = Examples::FooMod.bar(:arg1, 42, half: 21, &block)
      expect(result).to eq(
        bar: {
          args: [:arg1, 42],
          kw_args: {
            half: 21
          },
          block: block
        }
      )
    end

    it 'forwards parameters of class methods' do
      result = Examples::Foo.bar(:arg1, 42, half: 21, &block)
      expect(result).to eq(
        bar: {
          args: [:arg1, 42],
          kw_args: {
            half: 21
          },
          block: block
        }
      )
    end

    it 'forwards parameters of instance methods' do
      result = Examples::Foo.new.foo(:arg1, 42, half: 21, &block)
      expect(result).to eq(
        foo: {
          args: [:arg1, 42],
          kw_args: {
            half: 21
          },
          block: block
        }
      )
    end

    it 'forwards parameters of initialize' do
      result = Examples::Bar.new(:arg1, 42, half: 21, &block)
      expect(result.args).to eq(
        initialize: {
          args: [:arg1, 42],
          kw_args: {
            half: 21
          },
          block: block
        }
      )
    end
  end

  context 'reporting' do
    it 'reports when class methods of modules are called' do
      expect(Deprecations).to receive(:call).with(
        'Examples::FooMod.bar',
        'Examples::FooMod.alt_bar',
        'next version'
      )
      expect(Deprecations).to receive(:call).with(
        'Examples::FooMod.baz',
        nil,
        nil
      )
      Examples::FooMod.bar
      Examples::FooMod.baz(false)
    end

    it 'reports when class methods are called' do
      expect(Deprecations).to receive(:call).with(
        'Examples::Foo.bar',
        'Examples::Foo.alt_bar',
        'next version'
      )
      expect(Deprecations).to receive(:call).with('Examples::Foo.baz', nil, nil)
      Examples::Foo.bar
      Examples::Foo.baz(false)
    end

    it 'reports when instance methods are called' do
      expect(Deprecations).to receive(:call).with(
        'Examples::Foo#foo',
        'Examples::Foo#alt_foo',
        'next version'
      )
      expect(Deprecations).to receive(:call).with(
        'Examples::Foo#foo_baz',
        nil,
        nil
      )
      Examples::Foo.new.foo
      Examples::Foo.new.foo_baz(false)
    end

    it 'reports when class methods of a child class are called' do
      expect(Deprecations).to receive(:call).with(
        'Examples::FooChild.bar',
        'Examples::FooChild.alt_bar',
        'next version'
      )
      expect(Deprecations).to receive(:call).with(
        'Examples::FooChild.baz',
        nil,
        nil
      )
      Examples::FooChild.bar
      Examples::FooChild.baz(false)
    end

    it 'reports when instance methods of a child class are called' do
      expect(Deprecations).to receive(:call).with(
        'Examples::FooChild#foo',
        'Examples::FooChild#alt_foo',
        'next version'
      )
      expect(Deprecations).to receive(:call).with(
        'Examples::FooChild#foo_baz',
        nil,
        nil
      )
      Examples::FooChild.new.foo
      Examples::FooChild.new.foo_baz(false)
    end

    it 'reports when initialize is called' do
      expect(Deprecations).to receive(:call).with('Examples::Bar', nil, nil)
      Examples::Bar.new
    end
  end

  context 'error handling' do
    it 'raises a NameError for invalid deprecated method name' do
      expect { Class.new { deprecated :some } }.to raise_error(
        NameError,
        /some/
      )
    end

    it 'raises a NameError for invalid alternative method name' do
      expect do
        Class.new do
          def foo
            nil
          end

          deprecated :foo, :some
        end
      end.to raise_error(NameError, /some/)
    end

    it 'does not deprecate already deprecated class method' do
      expect(Examples::FooMod.__send__(:deprecated, :bar)).to be_nil
    end

    it 'does not deprecate already deprecated method' do
      expect(Examples::Foo.__send__(:deprecated, :foo)).to be_nil
    end
  end
end
