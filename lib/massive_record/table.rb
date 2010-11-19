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
        client.createTable(name, @column_families.collect{|cf| cf.descriptor}).nil?
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
      disable
      client.deleteTable(name).nil?
    end
    
    def create_column_families(column_family_names)
      column_family_names.each{|name| @column_families.push(ColumnFamily.new(name))}
    end
    
    def fetch_column_families
      @column_families = client.getColumnDescriptors(name).collect do |name, description| 
        ColumnFamily.new(name.split(":").first)
      end
    end
    
    def column_family_names
      client.getColumnDescriptors(name).collect{|column_name, description| column_name.split(":").first}
    end
    
    def scanner(opts = {})
      # list of column families to fetch from the db
      cols = opts[:column_family_names] || column_family_names
      
      s = Scanner.new(connection, self.name, cols)
      s.open
      s
    end
    
    def first
      scanner.fetch_rows(:limit => 1).first
    end
    
    def all(opts = {})
      scanner.fetch_rows(opts)
    end
    
    def exists?
      connection.tables.include?(name)
    end
    
  end
  
end