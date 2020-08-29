# frozen_string_literal: true

require_relative './lib/deprecations/version'

Gem::Specification.new do |gem|
  gem.name = 'deprecations'
  gem.version = Deprecations::VERSION
  gem.summary = 'Deprecation support for your project.'
  gem.description = <<~DESCRIPTION
    This gem provides transparent declaration of deprecated methods and classes.
    It's easy, small, has no dependencies and no overhead.
  DESCRIPTION
  gem.author = 'Mike Blumtritt'
  gem.homepage = 'https://github.com/mblumtritt/deprecations'
  gem.metadata = {
    'source_code_uri' => 'https://github.com/mblumtritt/deprecations',
    'bug_tracker_uri' => 'https://github.com/mblumtritt/deprecations/issues'
  }

  gem.required_ruby_version = '>= 2.0.0'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '>= 3.0.0'

  all_files = %x(git ls-files -z).split(0.chr)
  gem.test_files = all_files.grep(%r{^(spec|test)/})
  gem.files = all_files - gem.test_files
  gem.extra_rdoc_files = %w[README.md]
end
