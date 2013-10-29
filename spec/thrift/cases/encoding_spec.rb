# encoding: utf-8
require 'spec_helper'

describe "encoding" do
  before :all do
    @table_name = "encoding_test" + ActiveSupport::SecureRandom.hex(3)
  end

  before do
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new(MR_CONFIG['host'], 9090))
    protocol  = Thrift::BinaryProtocol.new(transport)
    @client   = Apache::Hadoop::Hbase::Thrift::Hbase::Client.new(protocol)
    
    transport.open()
    
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
    @client.mutateRow(@table_name, "ID1", [m], {}).should be_nil

    row = @client.getRow(@table_name, "ID1", {})[0].columns['info:first_name']
    row.value.should == "Vincent"
  end
  
  it "should save UTF8 caracteres" do
    m        = Apache::Hadoop::Hbase::Thrift::Mutation.new
    m.column = "info:first_name"
    m.value  = "Thorbjørn"
    
    m.value.encoding.should == Encoding::UTF_8
    @client.mutateRow(@table_name, "ID1", [m], {}).should be_nil

    row = @client.getRow(@table_name, "ID1", {})[0].columns['info:first_name']
    row.value.should == "Thorbjørn"
  end
  
  it "should save JSON" do
    m        = Apache::Hadoop::Hbase::Thrift::Mutation.new
    m.column = "info:first_name"
    m.value  = { :p1 => "Vincent", :p2 => "Thorbjørn" }.to_json.force_encoding(Encoding::UTF_8)
    
    m.value.encoding.should == Encoding::UTF_8
    @client.mutateRow(@table_name, "ID1", [m], {}).should be_nil

    row = @client.getRow(@table_name, "ID1", {})[0].columns['info:first_name']
    JSON.parse(row.value).should == { 'p1' => "Vincent", 'p2' => "Thorbjørn" }
  end
  
  it "should take care of several encodings" do
    m1        = Apache::Hadoop::Hbase::Thrift::Mutation.new
    m1.column = "info:first_name"
    m1.value  = { :p1 => "Vincent", :p2 => "Thorbjørn" }.to_json.force_encoding(Encoding::UTF_8)
    
    m2        = Apache::Hadoop::Hbase::Thrift::Mutation.new
    m2.column = "info:company_name"
    m2.value  = "Thorbjørn"
    
    m1.value.encoding.should == Encoding::UTF_8
    m2.value.encoding.should == Encoding::UTF_8

    @client.mutateRow(@table_name, "ID1", [m1, m2], {}).should be_nil
  end
  
  it "should destroy the table" do
    @client.disableTable(@table_name).should be_nil
    @client.deleteTable(@table_name).should be_nil
  end
end
