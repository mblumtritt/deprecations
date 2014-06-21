require 'spec_helper'

RSpec.describe Deprecations::VERSION do
  it 'has format <major>.<minor>.<build>' do
    expect(subject).to match(/^\d{1,2}\.\d{1,2}\.\d{1,3}/)
  end
end
