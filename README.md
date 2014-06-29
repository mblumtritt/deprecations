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

you can specify which methods and classes are deprecated. To mark a method as deprecated is quite easy:

```ruby
class MySample

  def clear
    # something here
  end

  def clean
    clear
  end
  deprecate :clean, :clear, 'next version'

end
```

Whenever the method `MySample#clean` is called this warning appears:

> [DEPRECATION] `MySample#clean` is deprecated and will be outdated next version. Please use `MySample#clear` instead.

You can change this behavior by configure the Deprecations gem:

```ruby
Deprecations.configure do |config|
  config.behavior = :raise
end
```

Valid behaviors are:

- `:raise` will raise an `DeprecationException` when a deprecated method is called
- `:silence` will do nothing
- `:warn` will print a warning (default behavior)

Marking a complete class as deprecated will present the deprecation warning (or exception) whenever this class is instantiated:

```ruby
class MySample
  deprecated!
  
  # some more code here...
end
```

Please have a look at the [specs](https://github.com/mblumtritt/deprecations/blob/master/spec/deprecations_spec.rb) for detailed information and more samples.
