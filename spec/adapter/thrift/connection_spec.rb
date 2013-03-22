require 'spec_helper'

describe "A connection" do
  
  before do
    @connection = MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
  end
  
  after do
    @connection.close if @connection.open?
  end
  
  it "should have a host, port, and timeout attributes" do
    connections = [@connection, MassiveRecord::Wrapper::Connection.new(:host => "somewhere")]
    
    connections.each do |conn|
      conn.host.to_s.should_not be_empty
      conn.port.to_s.should_not be_empty
      conn.timeout.to_s.should_not be_empty
    end
  end
  
  it "should allow configurable timeouts" do
    connection = MassiveRecord::Wrapper::Connection.new(:host => "somewhere", :timeout => 5)
    connection.timeout.should be 5
  end
  
  it "should not be open" do
    @connection.open?.should be_false
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

  it "shouldn't trigger any error if we try to close a close connection" do
    @connection.close.should be_true
  end

  describe "catching errors" do
    it "should not be able to open a new connection with a wrong configuration and Raise an error" do
      @connection.port = 1234
      lambda { @connection.open }.should raise_error(MassiveRecord::Wrapper::Errors::ConnectionException)
    end

    it "should try to open a new connection when an IO error occured" do
      @connection.open
      Apache::Hadoop::Hbase::Thrift::Hbase::Client.any_instance.stub(:scannerGetList) do 
        raise ::Apache::Hadoop::Hbase::Thrift::IOError, "closed stream"
      end
      @connection.should_receive(:open).with(:reconnecting => true, :reason => ::Apache::Hadoop::Hbase::Thrift::IOError)
      @connection.scannerGetList("arg1", "arg2")
    end

    it "should try to open a new connection when some packets are lost" do
      @connection.open
      Apache::Hadoop::Hbase::Thrift::Hbase::Client.any_instance.stub(:scannerGetList) do 
        raise ::Thrift::TransportException
      end
      @connection.should_receive(:open).with(:reconnecting => true, :reason => ::Thrift::TransportException)
      @connection.scannerGetList("arg1", "arg2")
    end

    it "should try to open a new connection when getting table names fails" do
      @connection.open
      Apache::Hadoop::Hbase::Thrift::Hbase::Client.any_instance.stub(:getTableNames) do 
        raise ::Thrift::ApplicationException.new(::Thrift::ApplicationException::MISSING_RESULT, 'getTableNames failed: unknown result')
      end
      @connection.should_receive(:open).with(:reconnecting => true, :reason => ::Thrift::ApplicationException)
      @connection.tables
    end
  end
end
