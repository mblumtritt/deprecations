# configure RSpec
RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec){ |c| c.syntax = :expect }
  config.mock_with(:rspec){ |c| c.syntax = :expect }
end

require 'deprecations'
