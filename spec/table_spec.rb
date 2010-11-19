require File.join(File.dirname(__FILE__), 'spec_helper')

describe MassiveRecord::Table do
  
  before(:each) do
    @connection = MassiveRecord::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
    @connection.open
    
    @table = MassiveRecord::Table.new(@connection, MR_CONFIG['table'])
  end
  
  it "should not exists is the database" do
    @connection.tables.should_not include(@table.name)
  end
  
  it "should create a test table" do
    @table.save.should eql(true)
  end
  
  it "should not have any column families" do
    @table.column_families.should be_empty
  end
  
  it "should fetch column families from the database" do
    @table.fetch_column_families.should eql(0)
    @table.column_families.size.should eql(0)
  end
  
  it "should create a new column family" do
    
  end
  
  it "should contains one column family" do
    
  end
  
  it "should exists in the database" do
    @table.exists?.should eql(true)
  end
  
  it "should destroy the test table" do
    @table.destroy.should eql(true)
  end
  
end