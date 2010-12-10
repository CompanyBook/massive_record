# encoding: utf-8
require 'spec_helper'

describe "encoding" do

  before do
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new(MR_CONFIG['host'], 9090))
    protocol  = Thrift::BinaryProtocol.new(transport)
    @client   = Apache::Hadoop::Hbase::Thrift::Hbase::Client.new(protocol)
    
    transport.open()
    
    @table_name = "encoding_test"
    @column_family = "info:"
  end
  
  it "should create a new table" do
    column = Apache::Hadoop::Hbase::Thrift::ColumnDescriptor.new{|c| c.name = @column_family}
    @client.createTable(@table_name, [column]).should be_nil
  end
  
  it "should save standard caracteres" do
    m        = Apache::Hadoop::Hbase::Thrift::Mutation.new
    m.column = "info:first_name"
    m.value  = "Vincent"
    
    m.value.encoding.should == Encoding::UTF_8
    @client.mutateRow(@table_name, "ID1", [m]).should be_nil    
  end
  
  it "should save UTF8 caracteres" do
    pending "UTF8 enconding need to be fixed!"
    
    m        = Apache::Hadoop::Hbase::Thrift::Mutation.new
    m.column = "info:first_name"
    m.value  = "Thorbjørn"
    
    m.value.encoding.should == Encoding::UTF_8
    @client.mutateRow(@table_name, "ID1", [m]).should be_nil
  end
  
  it "should destroy the table" do
    @client.disableTable(@table_name).should be_nil
    @client.deleteTable(@table_name).should be_nil
  end
end