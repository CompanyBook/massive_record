require 'spec_helper'

describe MassiveRecord::Wrapper::Table do
  
  describe "with a new connection" do

    before do
      @connection = MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
      @connection.open
      
      @table = MassiveRecord::Wrapper::Table.new(@connection, MR_CONFIG['table'])
    end
  
    describe "and a new initialized table" do
    
      it "should not exists is the database" do
        @connection.tables.should_not include(MR_CONFIG['table'])
      end
    
      it "should not have any column families" do
        @table.column_families.should be_empty
      end

    end
    
    describe "and a new initialized table with column families" do 
    
      before do
        @table.column_families.create(MassiveRecord::Wrapper::ColumnFamily.new(:info, :max_versions => 3))
        @table.column_families.create(:misc)
      end
  
      it "should contains two column families" do
        @table.column_families.size.should == 2
      end
  
      it "should create a test table" do
        @table.save.should be_true
      end
    
      it "should load a table" do
        @connection.load_table(MR_CONFIG['table']).class.should eql(MassiveRecord::Wrapper::Table)
        @connection.tables.load(MR_CONFIG['table']).class.should eql(MassiveRecord::Wrapper::Table)
      end
      
      it "should fetch column families from the database" do
        @table.fetch_column_families.size.should == 2
      end
    
      it "should add a row" do
        row = MassiveRecord::Wrapper::Row.new
        row.id = "ID1"
        row.values = { 
          :info => { :first_name => "John", :last_name => "Doe", :email => "john@base.com" },
          :misc => { 
            :like => ["Eating", "Sleeping", "Coding"], 
            :dislike => {
              "Washing" => "Boring 6/10",
              "Ironing" => "Boring 8/10"
            },
            :empty => {},
            :value_to_increment => "1"
          }
        }
        row.table = @table
        row.save
      end
      
      it "should contains one row" do
        @table.all.size.should == 1
      end
      
      it "should load the first row" do
        @table.first.should be_a_kind_of(MassiveRecord::Wrapper::Row)
      end
        
      it "should list 5 column names" do
        @table.column_names.size.should == 7
      end
      
      it "should only load one column family" do
        @table.first(:select => ["info"]).column_families.should == ["info"]
        @table.all(:limit => 1, :select => ["info"]).first.column_families.should == ["info"]
        @table.find("ID1", :select => ["info"]).column_families.should == ["info"]
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
        row.save.should be_true
      end

      it "should have a updated_at for a row" do
        row = @table.first
        row.updated_at.should be_a_kind_of Time
      end

      it "should have an updated_at for the row which is taken from the last updated attribute" do
        sleep(1)
        row = @table.first
        row.update_columns({ :info =>  { :first_name => "New Bob" } })
        row.save

        sleep(1)

        row = @table.first

        row.columns["info:first_name"].created_at.should == row.updated_at
      end

      it "should have a new updated at for a row" do
        row = @table.first
        updated_at_was = row.updated_at

        sleep(1)

        row.update_columns({ :info =>  { :first_name => "Bob" } })
        row.save

        row = @table.first
        
        updated_at_was.should_not == row.updated_at
      end

      it "should return nil if no cells has been created" do
        row = MassiveRecord::Wrapper::Row.new
        row.updated_at.should be_nil
      end

      
      
      
      it "should merge data" do
        row = @table.first
        row.update_columns({ :misc => { :super_power => "Eating"} })
        row.columns.collect{|k, v| k if k.include?("misc:")}.delete_if{|v| v.nil?}.sort.should(
          eql(["misc:value_to_increment", "misc:like", "misc:empty", "misc:dislike", "misc:super_power"].sort)
        )
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
      
      it "should deserialize Array / Hash values from YAML automatically" do
        row = @table.first
        row.values["misc:like"].class.should eql(Array)
        row.values["misc:dislike"].class.should eql(Hash)
        row.values["misc:empty"].class.should eql(Hash)
      end
      
      it "should display the previous value (versioning) of the column 'info:first_name'" do
        pending "should we implement this, Vincent? :-)"
      
        row = @table.first
        row.values["info:first_name"].should eql("Bob")
        
        prev_row = row.prev
        prev_row.values["info:first_name"].should eql("John")
      end
      
      it "should be able to perform partial updates" do
        row = @table.first(:select => ["misc"])
        row.update_columns({ :misc => { :genre => "M" } })
        row.save
        
        row = @table.first
        row.values["info:first_name"].should == "Bob"
        row.values["misc:genre"].should == "M"
      end

      it "should be able to do atomic increment call on values" do
        row = @table.first
        row.values["misc:value_to_increment"].should == "1"

        result = row.atomic_increment("misc:value_to_increment")
        result.should == "2"
      end

      it "should be able to pass inn what to incremet by" do
        row = @table.first
        row.values["misc:value_to_increment"].should == "2"
        row.atomic_increment("misc:value_to_increment", 2)

        row = @table.first
        row.values["misc:value_to_increment"].should == "4"
      end
      
      it "should delete a row" do
        @table.first.destroy.should be_true
      end
      
      it "should not contains any row" do
        @table.first.should be_nil
      end
      
      it "should create 5 rows" do
        1.upto(5).each do |i|
          row = MassiveRecord::Wrapper::Row.new
          row.id = "ID#{i}"
          row.values = { :info => { :first_name => "John #{i}", :last_name => "Doe #{i}" } }
          row.table = @table
          row.save
        end
        
        @table.all.size.should == 5
      end
            
      it "should find rows" do
        ids_list = [["ID1"], ["ID1", "ID2", "ID3"]]
        ids_list.each do |ids|
          @table.find(ids).each do |row|
            ids.include?(row.id).should be_true
          end
        end
      end
      
      it "should collect 5 IDs" do
        @table.all.collect(&:id).should eql(1.upto(5).collect{|i| "ID#{i}"})
      end
      
      it "should iterate through a collection of rows" do
        @table.all.each do |row|
          row.id.should_not be_nil
        end
      end
      
      it "should iterate through a collection of rows using a batch process" do
        group_number = 0
        @table.find_in_batches(:batch_size => 2, :start => "ID2", :select => ["info"]) do |group|
          group_number += 1
          group.each do |row|
            row.id.should_not be_nil
          end
        end        
        group_number.should == 2
      end
      
      it "should exists in the database" do
        @table.exists?.should be_true
      end
  
      it "should destroy the test table" do
        @table.destroy.should be_true
      end
  
    end
  
  end
  
end
