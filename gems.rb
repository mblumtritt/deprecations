# frozen_string_literal: true

source 'https://rubygems.org'

group :development, :test do
  gem 'bundler'
  gem 'rake'
end

group :test do
  gem 'rspec', '>= 3.0.0'
end

gemspec
