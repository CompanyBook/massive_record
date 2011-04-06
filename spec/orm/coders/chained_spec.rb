require 'spec_helper'

describe MassiveRecord::ORM::Coders::Chained do
  let(:subject) do
    MassiveRecord::ORM::Coders::Chained.new({
      :load_with => MassiveRecord::ORM::Coders::JSON.new,
      :dump_with => MassiveRecord::ORM::Coders::JSON.new
    })
  end

  let(:code_with) { lambda { |value| ActiveSupport::JSON.encode(value) } }
  
  it_should_behave_like "an orm coder"
end
