require 'rake/clean'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

$stdout.sync = $stderr.sync = true

task(:default) { exec('rake --tasks') }

RSpec::Core::RakeTask.new do |t|
  t.pattern = %w[spec/*_spec.rb spec/**/*/*_spec.rb]
  t.rspec_opts = '-w -fd'
  t.verbose = Rake.application.options.trace
end

task test: :spec
