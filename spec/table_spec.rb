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
    
      it "should load a table" do
        @connection.load_table(MR_CONFIG['table']).class.should eql(MassiveRecord::Table)
        @connection.tables.load(MR_CONFIG['table']).class.should eql(MassiveRecord::Table)
      end
      
      it "should fetch column families from the database" do
        @table.fetch_column_families.size.should eql(2)
      end
    
      it "should add a row" do
        row = MassiveRecord::Row.new
        row.id = "ID1"
        row.values = { 
          :info => { :first_name => "John", :last_name => "Doe", :email => "john@base.com" },
          :misc => { 
            :like => ["Eating", "Sleeping", "Coding"], 
            :dislike => {
              "Washing" => "Boring 6/10",
              "Ironing" => "Boring 8/10"
            }
          }
        }
        row.table = @table
        row.save
      end
      
      it "should contains one row" do
        @table.all.size.should eql(1)
      end
      
      it "should update row values" do
        row = @table.first
        row.values["info:first_name"].should eql("John")
        
        row.update_columns({ :info =>  { :first_name => "Bob" } })
        row.values["info:first_name"].should eql("Bob")
        
        row.update_column(:info, :email, "bob@base.com")
        row.values["info:email"].should eql("bob@base.com")
      end
      
      it "should save row changes" do
        row = @table.first
        row.update_columns({ :info => { :first_name => "Bob" } })
        row.save.should eql(true)
      end
      
      it "should merge data" do
        row = @table.first
        row.update_columns({ :misc => { :super_power => "Eating"} })
        row.columns.collect{|k, v| k if k.include?("misc:")}.delete_if{|v| v.nil?}.sort.should eql(["misc:like", "misc:dislike", "misc:super_power"].sort)
      end
      
      it "should merge array data" do
        row = @table.first
        row.merge_columns({ :misc => { :like => ["Playing"] } })
        row.columns["misc:like"].deserialize_value.should =~ ["Eating", "Sleeping", "Coding", "Playing"]
      end
      
      it "should merge hash data" do
        row = @table.first
        row.merge_columns({ :misc => { :dislike => { "Ironing" => "Boring 10/10", "Running" => "Boring 5/10" } } })
        row.columns["misc:dislike"].deserialize_value["Ironing"].should eql("Boring 10/10") # Check updated value
        row.columns["misc:dislike"].deserialize_value.keys.should =~ ["Washing", "Ironing", "Running"] # Check new value
      end
      
      it "should display the previous value (versioning) of the column 'info:first_name'" do
        pending
      
        row = @table.first
        row.values["info:first_name"].should eql("Bob")
        
        prev_row = row.prev
        prev_row.values["info:first_name"].should eql("John")
      end
      
      it "should delete a row" do
        @table.first.destroy.should eql(true)
      end
      
      it "should not contains any row" do
        @table.first.should eql(nil)
      end
      
      it "should create 5 rows" do
        1.upto(5).each do |i|
          row = MassiveRecord::Row.new
          row.id = "ID#{i}"
          row.values = { :info => { :first_name => "John #{i}", :last_name => "Doe #{i}" } }
          row.table = @table
          row.save
        end
        
        @table.all.size.should eql(5)
      end
      
      it "should find 3 rows" do
        ids = ["ID1", "ID2", "ID3"]
        @table.find(ids).each do |row|
          ids.include?(row.id).should eql(true)
        end
      end
      
      it "should collect 5 IDs" do
        @table.all.collect(&:id).should eql(1.upto(5).collect{|i| "ID#{i}"})
      end
      
      it "should iterate through a collection of rows" do
        @table.all.each do |row|
          row.id.should_not eql(nil)
        end
      end
      
      it "should iterate through a collection of rows using a batch process" do
        group_number = 0
        @table.find_in_batches(:batch_size => 2, :start => "ID2") do |group|
          group_number += 1
          group.each do |row|
            row.id.should_not eql(nil)
          end
        end        
        group_number.should eql(2)
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