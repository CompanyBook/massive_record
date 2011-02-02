require 'spec_helper'
require 'orm/models/test_class'
require 'orm/models/person'

describe "configuration" do
  include MockMassiveRecordConnection

  before do
    @mock_connection = mock(MassiveRecord::Wrapper::Connection, :open => true)
    MassiveRecord::Wrapper::Connection.stub(:new).and_return(@mock_connection)
  end

  describe "connection" do
    it "should use connection_configuration if present" do
      TestClass.reset_connection!
      MassiveRecord::Wrapper::Connection.should_receive(:new).with(TestClass.connection_configuration)
      TestClass.connection
    end

    it "should not ask Wrapper::Base for a connection when Rails is not defined" do
      MassiveRecord::Wrapper::Base.should_not_receive(:connection)
      TestClass.connection
    end

    it "should use the same connection if asked twice" do
      TestClass.connection_configuration = {:host => "foo", :port => 9001}
      MassiveRecord::Wrapper::Connection.should_receive(:new).once.and_return(@mock_connection)
      2.times { TestClass.connection }
    end

    it "should use the same connection for different sub classes" do
      TestClass.connection_configuration = {:host => "foo", :port => 9001}
      MassiveRecord::Wrapper::Connection.should_receive(:new).and_return(@mock_connection)
      TestClass.connection.should == Person.connection
    end

    it "should raise an error if connection configuration is missing" do
      TestClass.connection_configuration = {}
      lambda { TestClass.connection }.should raise_error MassiveRecord::ORM::ConnectionConfigurationMissing
    end

    it "should return an opened connection" do
      @mock_connection = mock(MassiveRecord::Wrapper::Connection)
      @mock_connection.should_receive(:open)
      MassiveRecord::Wrapper::Connection.should_receive(:new).and_return(@mock_connection)

      TestClass.connection
    end


    describe "under Rails" do
      before do
        TestClass.connection_configuration = {}
        module ::Rails; end
        MassiveRecord::Wrapper::Base.stub!(:connection).and_return(@mock_connection)
      end
      
      after do
        Object.send(:remove_const, :Rails)
      end

      it "should simply call Wrapper::Base" do
        MassiveRecord::Wrapper::Base.should_receive(:connection).and_return(@mock_connection)
        TestClass.connection.should == @mock_connection
      end

      it "should use connection_configuration if defined" do
        TestClass.connection_configuration = {:host => "foo", :port => 9001}
        MassiveRecord::Wrapper::Connection.should_receive(:new).with(TestClass.connection_configuration)
        TestClass.connection
      end
    end
  end



  describe "table" do
    it "should create a new wrapper table instance" do
      table_name = "TestClasss"
      connection = "dummy_connection"

      TestClass.should_receive(:table_name).and_return(table_name)
      TestClass.should_receive(:connection).and_return(connection)
      MassiveRecord::Wrapper::Table.should_receive(:new).with(connection, table_name)

      TestClass.table
    end

    it "should not reinitialize the same table twice" do
      MassiveRecord::Wrapper::Table.should_receive(:new).twice
      2.times { TestClass.table }
      2.times { Person.table }
    end

    it "should not return the same table for two different sub classes" do
      TestClass.table.should_not == Person.table
    end

    it "should use the same conncetion for two tables" do
      TestClass.table.connection.should == Person.table.connection
    end
  end
end
