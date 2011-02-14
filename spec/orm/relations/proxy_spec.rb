require 'spec_helper'

class TestProxy < MassiveRecord::ORM::Relations::Proxy; end

describe TestProxy do
  let(:metadata) { MassiveRecord::ORM::Relations::Metadata.new :person }
  
  before do
    subject.metadata = metadata
  end

  it_should_behave_like "relation proxy"
end
