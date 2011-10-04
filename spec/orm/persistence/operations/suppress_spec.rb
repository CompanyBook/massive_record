require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Suppress do
  include MockMassiveRecordConnection

  let(:record) { TestClass.new("id-1") }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }


  describe "#execute" do
    it "returns true" do
      subject.execute.should be_true
    end
  end
end
