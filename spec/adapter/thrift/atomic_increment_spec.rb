require 'spec_helper'

describe MassiveRecord::Wrapper::Row do
  before :all do
    @connection = MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
    @connection.open
    @table = MassiveRecord::Wrapper::Table.new(@connection, MR_CONFIG['table']).tap do |table|
      table.column_families.create(:misc)
      table.save
    end
  end

  after do
    @table.all.each &:destroy
  end
  
  after :all do
    @table.destroy
    @connection.close
  end

  
  let(:atomic_inc_attr_name) { 'misc:atomic' }
  subject do
    MassiveRecord::Wrapper::Row.new.tap do |row|
      row.id = "ID1"
      row.table = @table
      row.save
    end
  end




  describe "#atomic_increment" do
    it "increments to 1 when called on a new value" do
      subject.atomic_increment(atomic_inc_attr_name).should eq 1
    end

    it "increments by 2 when asked to do so" do
      subject.atomic_increment(atomic_inc_attr_name, 2).should eq 2
    end
  end

  describe "#read_atomic_integer_value" do
    it "returns 0 if no atomic increment operation has been performed" do
      subject.read_atomic_integer_value(atomic_inc_attr_name).should eq 0
    end

    it "returns 1 after one incrementation of 1" do
      subject.atomic_increment(atomic_inc_attr_name)
      subject.read_atomic_integer_value(atomic_inc_attr_name).should eq 1
    end
  end
end
