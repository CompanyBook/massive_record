require File.join(File.dirname(__FILE__), 'spec_helper')

describe MassiveRecord::Table do
  
  context "with a new connection" do

    before(:each) do
      @connection = MassiveRecord::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
      @connection.open
      
      @table = MassiveRecord::Table.new(@connection, MR_CONFIG['table'])
    end
  
    context "and a new initialized table" do
    
      it "should not exists is the database" do
        @connection.tables.should_not include(MR_CONFIG['table'])
      end
    
      it "should not have any column families" do
        @table.column_families.should be_empty
      end

    end
    
    context "and a new initialized table with column families" do 
    
      before(:each) do
        @table.column_families.create(MassiveRecord::ColumnFamily.new(:info, :max_versions => 3))
        @table.column_families.create(:misc)
      end
  
      it "should contains two column families" do
        @table.column_families.size.should eql(2)
      end
  
      it "should create a test table" do
        @table.save.should eql(true)
      end
    
      it "should fetch column families from the database" do
        @table.fetch_column_families.size.should eql(2)
      end
    
      it "should add a row" do
        row = MassiveRecord::Row.new
        row.id = "ID1"
        row.values = { :info =>  { :first_name => "John", :last_name => "Doe", :email => "john@base.com" } }
        row.table = @table
        row.save
      end
      
      it "should contains one row" do
        @table.all.size.should eql(1)
      end
      
      it "should update row values" do
        row = @table.first
        row.values["info:first_name"].should eql("John")
        
        row.update_values({ :info =>  { :first_name => "Bob" } })
        row.values["info:first_name"].should eql("Bob")
        
        row.update_value(:info, :email, "bob@base.com")
        row.values["info:email"].should eql("bob@base.com")
      end
      
      it "should save row changes" do
        row = @table.first
        row.update_values({ :info =>  { :first_name => "Bob" } })
        row.save.should eql(true)
      end
      
      it "should display the previous or next value (versioning) of the column 'info:first_name'" do
        row = @table.first
        row.values["info:first_name"].should eql("Bob")
        
        prev_row = row.prev
        prev_row.values["info:first_name"].should eql("John")
        
        next_row = prev_row.next
        next_row.values["info:first_name"].should eql("Bob")
      end
      
      it "should delete a row" do
        @table.first.destroy.should eql(true)
      end
  
      it "should not contains any row" do
        @table.first.should eql(nil)
      end
  
      it "should exists in the database" do
        @table.exists?.should eql(true)
      end
  
      it "should destroy the test table" do
        @table.destroy.should eql(true)
      end
  
    end
  
  end
  
end