require 'spec_helper'

describe MassiveRecord::ORM::Coders::JSON do
  let(:code_with) { lambda { |value| ActiveSupport::JSON.encode(value) } }
  it_should_behave_like "an orm coder"
end
