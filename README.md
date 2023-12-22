# Deprecations

This gem provides transparent declaration of deprecated methods and classes. It's easy, small, has no dependencies and no overhead.

## Installation

The simplest way to install Deprecations gem is to use [Bundler](http://gembundler.com/).

Add Deprecations to your `Gemfile`:

```ruby
gem 'deprecations'
```

and install it by running Bundler:

```shell
$ bundle add deprecations
```

To install the gem globally use:

```shell
$ gem install deprecations
```

## Usage

After adding the gem to your project

```ruby
require 'deprecations'
```

you can specify which methods and classes are deprecated. To mark a method as deprecated is quite easy:

```ruby
class MySample
  def clear
    # something here
  end

  def clean
    clear
  end

  deprecated :clean, :clear, 'next version'
end
```

Whenever the method `MySample#clean` is called this warning appears:

> warning: `MySample#clean` is deprecated and will be outdated next version. Please use `MySample#clear` instead.

Marking a complete class as deprecated will present the deprecation warning whenever this class is instantiated:

```ruby
class MySample
  deprecated!

  # some more code here...
end
```

You can change the behavior of notifying:

```ruby
Deprecations.behavior = :raise
```

There are 3 pre-defined behaviors:

- `:raise` will raise an `DeprecationException` when a deprecated method is called
- `:silence` will do nothing (ignore the deprecation)
- `:warn` will print a warning (default behavior)

Besides this you can implement your own:

```ruby
Deprecations.behavior =
  proc do |subject, _alternative, _outdated|
    SuperLogger.warning "deprecated: #{subject}"
  end
```

Any object responding to `#call` will be accepted as a valid handler.

Whenever you need to temporary change the standard behavior (like e.g. in your specs) you can do this like

```ruby
Deprecations.with_behavior(:silent) { MyDeprecatedClass.new.do_some_magic }
```

Please have a look at the [specs](https://github.com/mblumtritt/deprecations/blob/master/spec/deprecations_spec.rb) for detailed information and more samples.
