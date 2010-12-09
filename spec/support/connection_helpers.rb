module SetUpHbaseConnectionBeforeAll
  extend ActiveSupport::Concern

  included do
    before(:all) do
      unless @connection
        @connection_configuration = {:host => MR_CONFIG['host'], :port => MR_CONFIG['port']}
        @connection = MassiveRecord::Wrapper::Connection.new(@connection_configuration)
        @connection.open
      end
    end
  end
end


module CreatePersonBeforeEach
  extend ActiveSupport::Concern

  included do
    include SetUpHbaseConnectionBeforeAll

    before do
      Person.stub!(:table_name).and_return(MR_CONFIG['table'])
      Person.connection_configuration = @connection_configuration
      @table = MassiveRecord::Wrapper::Table.new(@connection, Person.table_name)
      @table.column_families.create(:info)
      @table.save
      
      @row = MassiveRecord::Wrapper::Row.new
      @row.id = "ID1"
      @row.values = {:info => {:name => "John Doe", :email => "john@base.com", :age => "20"}}
      @row.table = @table
      @row.save
    end

    after do
      @table.destroy 
    end
  end
end
