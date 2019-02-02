# frozen_string_literal: true

require_relative './lib/deprecations/version'

Gem::Specification.new do |spec|
  spec.name = spec.rubyforge_project = 'deprecations'
  spec.version = Deprecations::VERSION
  spec.summary = 'Deprecation support for your project.'
  spec.description = <<~DESCRIPTION
    This gem provides transparent declaration of deprecated methods and classes.
    It's easy, small, has no dependencies and no overhead.
  DESCRIPTION
  spec.author = 'Mike Blumtritt'
  spec.email = 'mike.blumtritt@pm.me'
  spec.homepage = 'https://github.com/mblumtritt/deprecations'
  spec.metadata = {'issue_tracker' => 'https://github.com/mblumtritt/deprecations/issues'}

  spec.add_development_dependency 'bundler', '>= 1.10'
  spec.add_development_dependency 'rake', '>= 10.1.1'
  spec.add_development_dependency 'rspec', '>= 3.0.0'

  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.0.0'
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.10.0')

  spec.require_paths = %w[lib]

  all_files = %x(git ls-files -z).split(0.chr)
  spec.test_files = all_files.grep(%r{^(spec|test)/})
  spec.files = all_files - spec.test_files

  spec.extra_rdoc_files = %w[README.md]
end
