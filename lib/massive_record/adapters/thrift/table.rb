module MassiveRecord
  module Adapters
    module Thrift
      class Table
        
        attr_accessor :connection, :name, :column_families
    
        def initialize(connection, table_name)
          @connection = connection
          @name = table_name.to_s
          init_column_families
        end
    
        def init_column_families      
          @column_families = MassiveRecord::Wrapper::ColumnFamiliesCollection.new
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
          @table_exists = false
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
          scanner = Scanner.new(connection, name, column_family_names, format_options_for_scanner(opts))
        
          if block_given?
            begin
              scanner.open
              yield scanner
            ensure
              scanner.close
            end
          else
            scanner
          end
        end
      
        def format_options_for_scanner(opts = {})
          {
            :start_key  => opts[:start],
            :offset_key => opts[:offset],
            :created_at => opts[:created_at],
            :columns    => opts[:select], # list of column families to fetch from hbase
            :limit      => opts[:limit] || opts[:batch_size]
          }
        end
      
        def all(opts = {})
          rows = []
          
          find_in_batches(opts) do |batch|
            rows |= batch
          end
          
          rows
        end
      
        def first(opts = {})
          all(opts.merge(:limit => 1)).first
        end
        
        #
        # Fast way of fetching the value of the cell
        # table.get("my_id", :info, :name) # => "Bob"
        #
        def get(id, column_family_name, column_name)
          if value = connection.get(name, id, "#{column_family_name.to_s}:#{column_name.to_s}").first.try(:value)
            MassiveRecord::Wrapper::Cell.new(:value => value).value # might seems a bit strange.. Just to "enforice" that the value is a supported type
          end
        end
        
        #
        # Finds one or multiple ids
        #
        # Returns nil if id is not found
        #
        def find(*args)
          what_to_find = args.first
          options = args.extract_options!.symbolize_keys

          if what_to_find.is_a?(Array)
            what_to_find.collect { |id| find(id, options) }
          else
            if column_families_to_find = options[:select]
              column_families_to_find = column_families_to_find.collect { |c| c.to_s }
            end

            if t_row_result = connection.getRowWithColumns(name, what_to_find, column_families_to_find).first
              Row.populate_from_trow_result(t_row_result, connection, name, column_families_to_find)
            end
          end
        end

        def find_in_batches(opts = {})        
          results_limit = opts[:limit]
          results_found = 0
          
          scanner(opts) do |s|
            while (true) do
              s.limit = results_limit - results_found if !results_limit.nil? && results_limit <= results_found + s.limit
              
              rows = s.fetch_rows
              if rows.empty?
                break
              else
                results_found += rows.size
                yield rows
              end
            end
          end
        end
    
        def exists?
          @table_exists ||= connection.tables.include?(name)
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
end
