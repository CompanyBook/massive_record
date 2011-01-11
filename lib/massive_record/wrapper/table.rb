module MassiveRecord
  module Wrapper
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
        connection
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
      
      def column_names
        first.column_names
      end
    
      def scanner(opts = {})
        # list of column families to fetch from hbase
        cols = opts[:column_family_names] || column_family_names
        
        Scanner.new(connection, self.name, cols, {
          :start_key  => opts[:start_key].to_s,
          :created_at => opts[:created_at].to_s
        })
      end
    
      def first(opts = {})
        all(opts.merge(:limit => 1)).first
      end
    
      def all(opts = {})
        scanner({:start_key => opts.delete(:start), :column_family_names => opts.delete(:select)}).fetch_rows(opts)
      end
    
      def find!(*args)
        results = find(*args)
        raise "Row not found." unless results.is_a?(MassiveRecord::Wrapper::Row) || (results.is_a?(Array) && !results.empty?)
        results
      end
    
      def find(*args)
        arg  = args[0]
        opts = args[1] || {}
        arg.is_a?(Array) ? arg.collect{|id| first(opts.merge(:start => id))} : first(opts.merge(:start => arg))
      end
    
      def find_in_batches(opts = {}, &block)
        raise "A block is required." unless block_given?
      
        opts[:limit]  = opts.delete(:batch_size) || 10
        opts[:limit] += 1
      
        prev_results = []
      
        while (true) do
          results = all(opts)
        
          if results != prev_results
            prev_results.empty? ? results.pop : results.shift
            if results.empty?
              break
            else
              opts[:start] = results.last.id
              yield results
            end
            prev_results = results
          end
        end
      end
    
      def exists?
        connection.tables.include?(name)
      end
    
      def regions
        connection.getTableRegions(name).collect do |r|
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
end