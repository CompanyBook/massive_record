require File.join(File.dirname(__FILE__), 'spec_helper')

describe MassiveRecord::Table do
  
  before(:each) do
    @connection = MassiveRecord::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
    @connection.open
    
    @table = MassiveRecord::Table.new(@connection, MR_CONFIG['table'])
  end
  
  it "should not include the test table" do
    @connection.tables.should_not include(@table.name)
  end
  
  it "should create a test table" do
    @table.save.should eql(true)
  end
  
  it "should include the test table" do
    @table.exists?.should eql(true)
  end
  
  it "should destroy the test table" do
    @table.destroy.should eql(true)
  end
  
end