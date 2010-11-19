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
    @table.fetch_column_families.should be_empty
  end
  
  it "should create two new column families" do
    column_family = MassiveRecord::ColumnFamily.new(:info)
    @table.column_families.create(column_family).should eql(true)
    @table.column_families.create(:misc, :max_versions => 3).should eql(true)
  end
  
  it "should contains two column families" do
    @table.column_families.size.should eql(2)
  end
  
  it "should add a row" do
    row = MassiveRecord::Row.new
    row.id = "ID1"
    row.values = { "info:first_name" => "H", "info:last_name" => "Base", "info:email" => "h@base.com" }
    row.table = @table
    row.save
  end
  
  it "should contains one row" do
    @table.all.size.should eql(1)
  end
  
  it "should delete a row" do
    @table.destroy_all.should eql(true)
  end
  
  it "should not contains any row" do
    @table.first.should eql(nil)
  end
  
  it "should exists in the database" do
    @table.exists?.should eql(true)
  end
  
  it "should destroy the test table" do
    @table.destroy.should eql(true)
  end
  
end