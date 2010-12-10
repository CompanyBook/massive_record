require 'spec_helper'

describe MassiveRecord::Wrapper::Connection do
  
  before do
    @connection = MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
  end
  
  it "should have a host and port attributes" do
    connections = [@connection, MassiveRecord::Wrapper::Connection.new(:host => "somewhere")]
    
    connections.each do |conn|
      conn.host.to_s.should_not be_empty
      conn.port.to_s.should_not be_empty
    end
  end 
  
  it "should not be active" do
    pending "should we implement this, Vincent? :-)"
    @connection.active?.should be_false
  end
   
  it "should not be able to open a new connection with a wrong configuration and Raise an error" do
    @connection.port = 1234
    lambda{@connection.open}.should raise_error(MassiveRecord::ConnectionException)
  end
  
  it "should be able to open a new connection with a good configuration" do
    @connection.open.should be_true
  end
  
  it "should not be active if it is closed" do 
    pending "should we implement this, Vincent? :-)"
    @connection.close.should be_true
    @connection.active?.should be_false
  end
  
  it "should have a collection of tables" do
    @connection.open
    @connection.tables.should be_a_kind_of(MassiveRecord::Wrapper::TablesCollection)
  end
  
end
