require 'spec_helper'
require 'orm/models/basic'

describe "configuration" do
  after do
    Basic.connection_configuration = {}
    Basic.unmemoize_all
  end


  it "should have a connection_configuration reader defined" do
    Basic.connection_configuration.should == {}
  end

  it "should use connection_configuration if present" do
    Basic.connection_configuration = {:host => "foo", :port => 9001}
    MassiveRecord::Wrapper::Connection.should_receive(:new).with(Basic.connection_configuration)
    Basic.connection
  end

  it "should not ask Wrapper::Base for a connection when Rails is not defined" do
    MassiveRecord::Wrapper::Base.should_not_receive(:connection)
    Basic.connection
  end

  it "should use the same connection if asked twice" do
    @dummy_connection = "dummy_connection"
    Basic.connection_configuration = {:host => "foo", :port => 9001}
    MassiveRecord::Wrapper::Connection.should_receive(:new).once.and_return(@dummy_connection)
    2.times { Basic.connection }
  end

  it "should be possible to reload the connection" do
    @dummy_connection = "dummy_connection"
    Basic.connection_configuration = {:host => "foo", :port => 9001}
    MassiveRecord::Wrapper::Connection.should_receive(:new).twice.and_return(@dummy_connection)
    2.times { Basic.connection(:reload) }
  end


  describe "under Rails" do
    before do
      module Rails; end
      @dummy_connection = "dummy_connection"
      MassiveRecord::Wrapper::Base.stub!(:connection).and_return(@dummy_connection)
    end
    
    after do
      Object.send(:remove_const, :Rails)
    end

    it "should simply call Wrapper::Base" do
      MassiveRecord::Wrapper::Base.should_receive(:connection).and_return(@dummy_connection)
      Basic.connection.should == @dummy_connection
    end

    it "should use connection_configuration if defined" do
      Basic.connection_configuration = {:host => "foo", :port => 9001}
      MassiveRecord::Wrapper::Connection.should_receive(:new).with(Basic.connection_configuration)
      Basic.connection
    end
  end

end
