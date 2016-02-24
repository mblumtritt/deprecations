guard(
  :rspec,
  cmd: 'bundle exec rspec -c',
  spec_paths: ['spec'],
  failed_mode: :focus,
  all_on_start: true,
  all_after_pass: true
) do
  watch(%r{^spec/.+_spec.rb$})
  watch(%r{^lib/.+.rb$}){ 'spec' }
  watch(%r{^spec/spec_helper}){ 'spec' }
end
