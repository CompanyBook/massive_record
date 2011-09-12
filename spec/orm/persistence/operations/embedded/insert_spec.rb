require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Embedded::Insert do
  include MockMassiveRecordConnection

  let(:record) { Address.new("id-1") }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }

  it_should_behave_like "a persistence embedded operation class"


  describe "#execute" do
    pending
  end
end
