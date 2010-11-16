module MassiveRecord
  
  class Table
        
    attr_accessor :connection, :name, :column_families
    
    def initialize(connection, table_name)
      @connection = connection
      @name = table_name.to_s
      @column_families = []
    end
    
    def self.create(connection, table_name, column_families = [])
      table = self.new(connection, table_name)
      table.column_families = column_families
      table.save
    end
    
    def save
      begin
        client.createTable(name, @column_families.collect{|cf| cf.descriptor})
      rescue Apache::Hadoop::Hbase::Thrift::AlreadyExists => ex
        "The table already exists."
      rescue => ex
        raise ex
      end
    end
    
    def client
      connection.client
    end    
    
    def disable
      client.disableTable(name)
    end
    
    def destroy
      client.deleteTable(name)
    end
    
    def fetch_column_families
      @column_families = client.getColumnDescriptors(name).collect do |column_name, description| 
        MassiveRecord::ColumnFamily.new(column_name.split(":").first)
      end
    end
    
    def column_families_names
      client.getColumnDescriptors(name).collect{|column_name, description| column_name.split(":").first}
    end
    
    def scanner(opts = {})
      # list of column families to fetch from the db
      cols = opts[:column_families_names] || column_families_names
      
      s = MassiveRecord::Scanner.new(connection, self.name, cols)
      s.open
      s
    end
    
    def first
      scanner.fetch_rows(:limit => 1).first
    end
    
    def all(opts = {})
      scanner.fetch_rows(opts)
    end
    
  end
  
end