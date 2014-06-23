require 'spec_helper'

RSpec.describe 'Deprecations::Configuration' do
  it 'is possible to configure the module' do
    Deprecations.configure do |config|
      config.behavior = :silent
    end
    expect(Deprecations.configuration.behavior).to be :silent
  end

  context 'when invalid arguments are given' do
    it 'raises an error' do
      expect do
        Deprecations.configure do |config|
          config.behavior = :invalid_value
        end
      end.to raise_error(ArgumentError, /invalid_value/)
    end
  end
end
