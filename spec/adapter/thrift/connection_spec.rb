require 'spec_helper'

describe "A connection" do
  
  let(:subject) { MassiveRecord::Wrapper::Connection }
  let(:conn) { subject.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port']) }  

  it "should populate the port" do
    conn.port.should == MR_CONFIG['port']
  end
  
  it "should have a default timeout of 4 seconds" do
    conn.timeout.should == 4
  end
  
  it "should allow configurable timeouts" do
    conn = subject.new(:timeout => 5)
    conn.timeout.should be 5
  end
  
  it "should not be open be default" do
    conn.open?.should be_false
  end
  
  it "should be open if opened" do
    conn.open.should be_true
    conn.open?.should be_true
    conn.close
  end
  
  it "should not be open if closed" do
    conn.open.should be_true
    conn.close.should be_true
    conn.open?.should be_false
  end
  
  it "should have a collection of tables" do
    conn.open
    conn.tables.should be_a_kind_of(MassiveRecord::Wrapper::TablesCollection)
    conn.close
  end

  it "shouldn't trigger any error if we try to close a close connection and there is no open connection" do
    conn.close.should be_true
  end

  describe "catching errors" do
    it "should not be able to open a new connection with a wrong configuration and Raise an error" do
      conn.port = 1234
      lambda { conn.open }.should raise_error(MassiveRecord::Wrapper::Errors::ConnectionException)
    end

    it "should try to open a new connection when an IO error occured" do
      conn.open
      Apache::Hadoop::Hbase::Thrift::Hbase::Client.any_instance.stub(:scannerGetList) do 
        raise ::Apache::Hadoop::Hbase::Thrift::IOError, "closed stream"
      end
      conn.should_receive(:open).with(:reconnecting => true, :reason => ::Apache::Hadoop::Hbase::Thrift::IOError)
      conn.scannerGetList("arg1", "arg2")
    end

    it "should try to open a new connection when some packets are lost" do
      conn.open
      Apache::Hadoop::Hbase::Thrift::Hbase::Client.any_instance.stub(:scannerGetList) do 
        raise ::Thrift::TransportException
      end
      conn.should_receive(:open).with(:reconnecting => true, :reason => ::Thrift::TransportException)
      conn.scannerGetList("arg1", "arg2")
    end

    it "should try to open a new connection when getting table names fails" do
      conn.open
      Apache::Hadoop::Hbase::Thrift::Hbase::Client.any_instance.stub(:getTableNames) do 
        raise ::Thrift::ApplicationException.new(::Thrift::ApplicationException::MISSING_RESULT, 'getTableNames failed: unknown result')
      end
      conn.should_receive(:open).with(:reconnecting => true, :reason => ::Thrift::ApplicationException)
      conn.tables
    end
  end

  describe "host(s)" do
    it "should have a host populated" do
      conn = subject.new(:host => "12.34.56.78")
      conn.host.should == "12.34.56.78"
    end    

    it "should have a pool of hosts" do
      conn = subject.new(:hosts => ["12.34.56.78", "34.56.78.90"])
      conn.hosts.should == ["12.34.56.78", "34.56.78.90"]
    end

    it "should have a current_host empty by default" do
      conn = subject.new(:host => "12.34.56.78")
      conn.current_host.should be_nil
    end

    it "should populate current_host according to host" do
      conn = subject.new(:host => "12.34.56.78")
      conn.send(:populateCurrentHost)
      conn.current_host.should == "12.34.56.78"
    end

    it "should populate current_host according to hosts" do
      conn = subject.new(:hosts => ["90.34.56.78", "34.56.78.90"])
      conn.send(:populateCurrentHost)
      ["90.34.56.78", "34.56.78.90"].should include(conn.current_host)
      selectedHost = conn.current_host

      nextSelectedHost = ["90.34.56.78", "34.56.78.90"]
      nextSelectedHost.delete(conn.current_host)
      nextSelectedHost = nextSelectedHost.first
      conn.send(:populateCurrentHost)      
      conn.current_host.should == nextSelectedHost
    end
  end
end
