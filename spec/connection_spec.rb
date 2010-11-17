require File.join(File.dirname(__FILE__), 'spec_helper')

describe "MassiveRecord Connection" do
  
  it "should have a host and port" do
    host = "somewhere.at.amazon.com"
    port = 9090
    
    conn = MassiveRecord::Connection.new(:host => host, :port => port)
    conn.host.should == host
    conn.port.should == port
  end 
  
end