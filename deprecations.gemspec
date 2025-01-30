# frozen_string_literal: true

require_relative 'lib/deprecations/version'

Gem::Specification.new do |spec|
  spec.name = 'deprecations'
  spec.version = Deprecations::VERSION
  spec.summary = 'Deprecation support for your project.'
  spec.description = <<~DESCRIPTION
    This gem provides transparent declaration of deprecated methods and classes.
    It's easy, small, has no dependencies and no overhead.
  DESCRIPTION

  spec.author = 'Mike Blumtritt'
  spec.homepage = 'https://github.com/mblumtritt/deprecations'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 3.0.0'
  spec.files = Dir['lib/**/*']
  spec.extra_rdoc_files = %w[README.md]
end
