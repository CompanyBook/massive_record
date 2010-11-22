module MassiveRecord
  
  class Table
        
    attr_accessor :connection, :name, :column_families
    
    def initialize(connection, table_name)
      @connection = connection
      @name = table_name.to_s
      init_column_families
    end
    
    def init_column_families      
      @column_families = ColumnFamiliesCollection.new
      @column_families.table = self
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
      client.disableTable(name).nil?
    end
    
    def destroy
      disable
      client.deleteTable(name).nil?
    end
    
    def create_column_families(column_family_names)
      column_family_names.each{|name| @column_families.push(ColumnFamily.new(name))}
    end
    
    def fetch_column_families
      @column_families.clear
      client.getColumnDescriptors(name).each do |column_name, description| 
        @column_families.push(ColumnFamily.new(column_name.split(":").first))
      end
      @column_families
    end
    
    def column_family_names
      @column_families.collect{|column_family| column_family.name.to_s}
    end
    
    def fetch_column_family_names
      fetch_column_families
      column_family_names
    end
    
    def scanner(opts = {})
      # list of column families to fetch from the db
      cols = opts[:column_family_names] || column_family_names
      sk   = opts[:start_key].to_s
      
      s = Scanner.new(connection, self.name, cols, sk)
      s.open
      s
    end
    
    def first
      scanner.fetch_rows(:limit => 1).first
    end
    
    def all(opts = {})
      scanner({:start_key => opts.delete(:start)}).fetch_rows(opts)
    end
    
    def find(id)
      scanner(:start_key => id).fetch_rows(:limit => 1).first
    end
    
    def exists?
      connection.tables.include?(name)
    end
    
    def regions
      connection.client.getTableRegions(name).collect do |r|
        {
          :start_key => r.startKey,
          :end_key => r.endKey,
          :id => r.id,
          :name => r.name,
          :version => r.version
        }
      end
    end
    
  end
  
end