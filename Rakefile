ENV.key?('NO_RUBYGEMS') or require('rubygems')
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = ['spec/*_spec.rb', 'spec/**/*/*_spec.rb']
  t.rspec_opts = '-w'
  t.verbose = Rake.application.options.trace
end

task default: :test
