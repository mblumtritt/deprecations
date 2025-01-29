# frozen_string_literal: true

$stdout.sync = $stderr.sync = true

require 'bundler/gem_tasks'
CLOBBER << 'prj'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test) { _1.ruby_opts = %w[-w] }

task(:default) { exec('rake --tasks') }
