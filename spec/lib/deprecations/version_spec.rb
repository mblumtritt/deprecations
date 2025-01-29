# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecations::VERSION' do
  subject(:version) { Deprecations::VERSION }

  it { is_expected.to be_frozen }
  it do
    is_expected.to match(
      /\A[[:digit:]]{1,3}.[[:digit:]]{1,3}.[[:digit:]]{1,3}(alpha|beta)?\z/
    )
  end
end
