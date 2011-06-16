require 'spec_helper'

describe "A table" do
  
  before(:all) do
    @connection = MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
    @connection.open
  end
  
  describe "with an open connection" do

    before do
      @table = MassiveRecord::Wrapper::Table.new(@connection, MR_CONFIG['table'])
    end
  
    describe "and a new initialized table" do
    
      it "should not exists is the database" do
        @connection.tables.should_not include(MR_CONFIG['table'])
      end

      it "should not exists in the database" do
        @table.exists?.should be_false
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
            :integer => 1234567,
            :null_test => "some-value",
            :like => ["Eating", "Sleeping", "Coding"].to_json, 
            :dislike => {
              "Washing" => "Boring 6/10",
              "Ironing" => "Boring 8/10"
            }.to_json,
            :empty => {}.to_json
          }
        }
        row.table = @table
        row.save
      end
              
      it "should list all column names" do
        @table.column_names.size.should == 8
      end
      
      it "should only load one column" do
        @table.get("ID1", :info, :first_name).should == "John"
      end

      it "should return nil if column does not exist" do
        @table.get("ID1", :info, :unkown_column).should be_nil
      end
      
      it "should only load one column family" do
        @table.first(:select => ["info"]).column_families.should == ["info"]
        @table.all(:limit => 1, :select => ["info"]).first.column_families.should == ["info"]
        @table.find("ID1", :select => ["info"]).column_families.should == ["info"]
      end

      it "should return nil if id is not found" do
        @table.find("not_exist_FOO").should be_nil
      end

      it "should update row values" do
        row = @table.first
        row.values["info:first_name"].should eql("John")
        
        row.update_columns({ :info =>  { :first_name => "Bob" } })
        row.values["info:first_name"].should eql("Bob")
        
        row.update_column(:info, :email, "bob@base.com")
        row.values["info:email"].should eql("bob@base.com")
      end

      it "should persist integer values as binary" do
        row = @table.first
        row.values["misc:integer"].should eq [1234567].pack('q').reverse
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
          eql(["misc:null_test", "misc:integer", "misc:like", "misc:empty", "misc:dislike", "misc:super_power"].sort)
        )
      end
      
      it "should deserialize Array / Hash values from YAML automatically" do
        row = @table.first
        ActiveSupport::JSON.decode(row.values["misc:like"]).class.should eql(Array)
        ActiveSupport::JSON.decode(row.values["misc:dislike"]).class.should eql(Hash)
        ActiveSupport::JSON.decode(row.values["misc:empty"]).class.should eql(Hash)
      end
      
      it "should be able to perform partial updates" do
        row = @table.first(:select => ["misc"])
        row.update_columns({ :misc => { :genre => "M" } })
        row.save
        
        row = @table.first
        row.values["info:first_name"].should == "Bob"
        row.values["misc:genre"].should == "M"
      end

      it "should be able to do atomic increment call on new cell" do
        row = @table.first

        result = row.atomic_increment("misc:value_to_increment")
        result.should == 1
      end

      it "should be able to pass in what to incremet the new cell by" do
        row = @table.first
        result = row.atomic_increment("misc:value_to_increment", 2)

        result.should == 3
      end

      it "should be able to do atomic increment on existing values" do
        row = @table.first

        result = row.atomic_increment("misc:integer")
        result.should == 1234568
      end

      it "should be settable to nil" do
        row = @table.first

        row.values["misc:null_test"].should_not be_nil

        row.update_column(:misc, :null_test, nil)
        row.save

        row = @table.first
        row.values["misc:null_test"].should be_nil
      end
      
      it "should delete a row" do
        @table.first.destroy.should be_true
      end
      
      it "should not contains any row" do
        @table.first.should be_nil
      end
      
      it "should exists in the database" do
        @table.exists?.should be_true
      end

      it "should only check for existance once" do
        connection = mock(Object)
        connection.should_receive(:tables).and_return [MR_CONFIG['table']] 
        @table.should_receive(:connection).and_return(connection)

        2.times { @table.exists? }
      end
  
      it "should destroy the test table" do
        @table.destroy.should be_true
      end
    end
  
  end
  
  describe "can be scanned" do
    before do
      @table = MassiveRecord::Wrapper::Table.new(@connection, MR_CONFIG['table'])
      @table.column_families.create(:info)
      @table.column_families.create(:misc)
      
      @table.save
      
      ["A", "B"].each do |prefix|
        1.upto(5).each do |i|
          row = MassiveRecord::Wrapper::Row.new
          row.id = "#{prefix}#{i}"
          row.values = { :info => { :first_name => "John #{i}", :last_name => "Doe #{i}" } }
          row.table = @table
          row.save
        end
      end
    end
    
    after do
      @table.destroy
    end
    
    it "should contains 10 rows" do
      @table.all.size.should == 10
      @table.all.collect(&:id).size.should == 10
    end
    
    it "should load the first row" do
      @table.first.should be_a_kind_of(MassiveRecord::Wrapper::Row)
    end
    
    it "should find rows from a list of IDs" do
      ids_list = [["A1"], ["A1", "A2", "A3"]]
      ids_list.each do |ids|
        @table.find(ids).each do |row|
          ids.include?(row.id).should be_true
        end
      end
    end
  
    it "should iterate through a collection of rows" do
      @table.all.each do |row|
        row.id.should_not be_nil
      end
    end
  
    it "should iterate through a collection of rows using a batch process" do
      group_number = 0
      @table.find_in_batches(:batch_size => 2, :select => ["info"]) do |group|
        group_number += 1
        group.each do |row|
          row.id.should_not be_nil
        end
      end        
      group_number.should == 5
    end
  
    it "should find 1 row using the :start option" do
      @table.all(:start => "A1").size.should == 1
    end
  
    it "should find 5 rows using the :start option" do
      @table.all(:start => "A").size.should == 5
    end
  
    it "should find 9 rows using the :offset option" do
      @table.all(:offset => "A2").size.should == 9
    end
    
    it "should find 4 rows using both :offset and :start options" do
      @table.all(:offset => "A2", :start => "A").size.should == 4
    end
  end
end
