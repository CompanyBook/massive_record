require 'spec_helper'

describe "A connection" do
  
  before do
    @connection = MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
  end
  
  after do
    @connection.close if @connection.open?
  end
  
  it "should have a host and port attributes" do
    connections = [@connection, MassiveRecord::Wrapper::Connection.new(:host => "somewhere")]
    
    connections.each do |conn|
      conn.host.to_s.should_not be_empty
      conn.port.to_s.should_not be_empty
    end
  end 
  
  it "should not be open" do
    @connection.open?.should be_false
  end
   
  it "should not be able to open a new connection with a wrong configuration and Raise an error" do
    @connection.port = 1234
    lambda{@connection.open}.should raise_error(MassiveRecord::Wrapper::Errors::ConnectionException)
  end
  
  it "should be open if opened" do
    @connection.open.should be_true
    @connection.open?.should be_true
  end
  
  it "should not be open if closed" do 
    @connection.open.should be_true
    @connection.close.should be_true
    @connection.open?.should be_false
  end
  
  it "should have a collection of tables" do
    @connection.open
    @connection.tables.should be_a_kind_of(MassiveRecord::Wrapper::TablesCollection)
  end
end
