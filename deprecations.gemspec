require File.expand_path('../lib/deprecations/version', __FILE__)

GemSpec = Gem::Specification.new do |spec|
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.0.0'
  spec.name = spec.rubyforge_project = 'deprecations'
  spec.version = Deprecations::VERSION
  spec.authors = ['Mike Blumtritt']
  spec.email = %w[mike.blumtritt@injixo.com]
  spec.summary = 'Deprecation support for your project.'
  spec.description = "This gem provides transparent declaration of deprecated methods and classes. "\
    "It's easy, small, has no dependencies and no overhead."
  spec.homepage = 'https://github.com/mblumtritt/deprecations'
  spec.licenses = ['MIT']
  spec.date = Time.now.strftime('%Y-%m-%d')
  spec.require_paths = %w[lib]
  spec.files = %x[git ls-files].split($/)
  spec.test_files = spec.files.grep(%r[^spec/])
  spec.extra_rdoc_files = %w[README.md CHANGELOG.md]
  spec.has_rdoc = false # TODO!
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
end
