require 'spec_helper'

describe MassiveRecord::Wrapper::Connection do
  
  before do
    @connection ||= MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
  end
  
  it "should have a host and port" do
    connections = [@connection, MassiveRecord::Wrapper::Connection.new(:host => "somewhere")]
    
    connections.each do |conn|
      conn.host.to_s.should_not be_empty
      conn.port.to_s.should_not be_empty
    end
  end 
  
  it "should open the connection" do
    @connection.open.class.should eql(Socket)
  end
  
  it "should have a list of tables" do
    @connection.open 
    @connection.tables.class.should eql(MassiveRecord::Wrapper::TablesCollection)
  end
  
end
