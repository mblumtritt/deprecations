require File.expand_path('../lib/deprecations/version', __FILE__)

FILES = %x(git ls-files).split($/)
GemSpec = Gem::Specification.new do |spec|
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.0.0'
  spec.name = spec.rubyforge_project = 'deprecations'
  spec.version = Deprecations::VERSION
  spec.summary = 'Deprecation support for your project.'
  spec.description = %w(
    This gem provides transparent declaration of deprecated methods and classes.
    It's easy, small, has no dependencies and no overhead.
  ).join(' ')
  spec.author = 'Mike Blumtritt'
  spec.email = 'mike.blumtritt@invision.de'
  spec.homepage = 'https://github.com/mblumtritt/deprecations'
  spec.metadata = {
    'issue_tracker' => 'https://github.com/mblumtritt/deprecations/issues'
  }
  spec.require_paths = %w(lib)
  spec.test_files = FILES.grep(%r{^(spec|test)/})
  spec.files = FILES - spec.test_files
  spec.has_rdoc = false
  spec.extra_rdoc_files = %w(README.md CHANGELOG.md)
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.1', '>= 10.1.1'
  spec.add_development_dependency 'rspec', '~> 3.0', '>= 3.0.0'
end
