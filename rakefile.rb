require 'rake/clean'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

STDOUT.sync = STDERR.sync = true

RSpec::Core::RakeTask.new do |t|
  t.pattern = %w[spec/*_spec.rb spec/**/*/*_spec.rb]
  t.rspec_opts = '-w -fd'
  t.verbose = Rake.application.options.trace
end
task test: :spec

task :default do
  exec "#{$PROGRAM_NAME} --task"
end
