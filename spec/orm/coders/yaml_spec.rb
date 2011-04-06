require 'spec_helper'

describe MassiveRecord::ORM::Coders::YAML do
  let(:code_with) { lambda { |value| value.to_yaml } }
  it_should_behave_like "an orm coder"
end
