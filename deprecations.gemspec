# frozen_string_literal: true

require_relative './lib/deprecations/version'

Gem::Specification.new do |spec|
  spec.name = 'deprecations'
  spec.version = Deprecations::VERSION
  spec.required_ruby_version = '>= 2.0.0'

  spec.summary = 'Deprecation support for your project.'
  spec.description = <<~DESCRIPTION
    This gem provides transparent declaration of deprecated methods and classes.
    It's easy, small, has no dependencies and no overhead.
  DESCRIPTION

  spec.author = 'Mike Blumtritt'
  spec.homepage = 'https://github.com/mblumtritt/deprecations'
  spec.metadata['source_code_uri'] =
    'https://github.com/mblumtritt/deprecations'
  spec.metadata['bug_tracker_uri'] =
    'https://github.com/mblumtritt/deprecations/issues'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'

  all_files = Dir.chdir(__dir__) { `git ls-files -z`.split(0.chr) }
  spec.test_files = all_files.grep(%r{^(spec|test)/})
  spec.files = all_files - spec.test_files
  spec.extra_rdoc_files = %w[README.md]
end
