require 'spec_helper'
require 'orm/models/basic'
require 'orm/models/person'

describe "configuration" do
  after do
    Basic.unmemoize_all
    Person.unmemoize_all
  end

  describe "connection" do
    it "should use connection_configuration if present" do
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

    it "should use the same connection for different sub classes" do
      @dummy_connection = "dummy_connection"
      Basic.connection_configuration = {:host => "foo", :port => 9001}
      MassiveRecord::Wrapper::Connection.should_receive(:new).and_return(@dummy_connection)
      Basic.connection.should == Person.connection
    end

    it "should raise an error if connection configuration is missing" do
      Basic.connection_configuration = {}
      lambda { Basic.connection }.should raise_error MassiveRecord::ORM::ConnectionConfigurationMissing
    end


    describe "under Rails" do
      before do
        Basic.connection_configuration = {}
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



  describe "table" do
    it "should create a new wrapper table instance" do
      table_name = "Basics"
      connection = "dummy_connection"

      Basic.should_receive(:table_name).and_return(table_name)
      Basic.should_receive(:connection).and_return(connection)
      MassiveRecord::Wrapper::Table.should_receive(:new).with(connection, table_name)

      Basic.table
    end

    it "should not reinitialize the same table twice" do
      MassiveRecord::Wrapper::Table.should_receive(:new).twice
      2.times { Basic.table }
      2.times { Person.table }
    end

    it "should not return the same table for two different sub classes" do
      Basic.table.should_not == Person.table
    end

    it "should use the same conncetion for two tables" do
      Basic.table.connection.should == Person.table.connection
    end
  end
end
