require File.expand_path('../lib/deprecations/version', __FILE__)

GemSpec= Gem::Specification.new do |spec|
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.0.0'
  spec.name = spec.rubyforge_project = 'deprecations'
  spec.version = Deprecations::VERSION
  spec.authors = ['Mike Blumtritt']
  spec.email = %w[mike.blumtritt@injixo.com]
  spec.summary = 'Deprecation support for your project.'
  spec.description = 'This gem provides transparent declaration of deprecated methods and classes.'
  spec.homepage = 'https://github.com/mblumtritt/deprecations'
  spec.date = Time.now.strftime('%Y-%m-%d')
  spec.require_paths = %w[lib]
  spec.files = %x[git ls-files].split($/)
  spec.test_files = spec.files.grep(%r[^test/])
  spec.extra_rdoc_files = %w[README.md]
  spec.has_rdoc = false # TODO!
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  if /darwin|mac os/i =~ RUBY_PLATFORM
    spec.add_development_dependency 'rb-fsevent'
    spec.add_development_dependency 'terminal-notifier-guard'
  end
end
