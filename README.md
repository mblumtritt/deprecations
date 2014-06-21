# Deprecations

This gem provides transparent declaration of deprecated methods and classes.

## Installation

The simplest way to install Deprecations gem is to use [Bundler](http://gembundler.com/).

Add Deprecations to your `Gemfile`:

```ruby
gem 'deprecations'
```

and install it by running Bundler:

```bash
$ bundle
```

To install the gem globally use:

```bash
$ gem install deprecations
```

## Usage

After adding the gem to your project

```ruby
require 'deprecations'
```

you can specify which methods and classes are deprecated. Whenever a deprecated method or class will be used a warning about it's deprecation will be given, containing the information about the calling source.

### Sample - Deprecated Method:
```ruby
Deprecations.deprecate(Foo, :foo, :bar)
```

Calling method `Foo#foo` will display a warning about it's deprecation. A suggestion to use method `Foo#bar` instead will be included. When `foo` is a class method this will work too (`Foo::foo` is deprecated then).

### Sample - Deprecated Class:
```ruby
Deprecations.deprecate(Foo, Bar)
```

Whenever `Foo` is instantiated a warning about it's deprecation will be displayed and using class `Bar` instead will be suggested.
