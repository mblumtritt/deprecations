require 'rake/clean'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

STDOUT.sync = STDERR.sync = true

CLOBBER << 'prj'

RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = ['spec/*_spec.rb', 'spec/**/*/*_spec.rb']
  t.rspec_opts = '-w'
  t.verbose = Rake.application.options.trace
end

task :default do
  exec "#{$PROGRAM_NAME} --task"
end
