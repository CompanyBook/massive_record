module MassiveRecord
  module Adapters
    module Thrift
      class Table
        
        attr_accessor :connection, :name, :column_families
    
        #
        # TODO
        # Helper method to inform about changed options. Remove this in next version..
        # Also note that this method is used other places to wrap same functionality.
        #
        def self.warn_and_change_deprecated_finder_options(options)
          deprecations = {
            :start => :starts_with
          }

          deprecations.each do |deprecated, current|
            if options.has_key? deprecated
              # TODO remove this for next version
              ActiveSupport::Deprecation.warn("finder option '#{deprecated}' is deprecated. Please use: '#{current}'")
              options[current] = options.delete deprecated
            end
          end
          
          options
        end

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
            result = client.createTable(name, @column_families.collect{|cf| cf.descriptor}).nil?
            sleep 0.5
            @table_exists = true
            result
          rescue ::Apache::Hadoop::Hbase::Thrift::AlreadyExists => ex
            "The table already exists."
          rescue => ex
            if ex.is_a?(::Apache::Hadoop::Hbase::Thrift::IOError) && ex.message.include?("TableExistsException")
              "The table already exists."
            else
              raise ex
            end
          end
        end
    
        def client
          connection
        end    
    
        def disable
          if client.isTableEnabled(name)
            client.disableTable(name).nil?
          end
        end
    
        def destroy
          disable
          if client.deleteTable(name).nil?
            sleep 0.5
            @table_exists = false
            true
          else
            false
          end
        rescue => e
          @table_exists = nil
          exists? ? raise(e) : true
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
          opts = self.class.warn_and_change_deprecated_finder_options(opts)

          start = opts[:starts_with] && opts[:starts_with]
          offset = opts[:offset] && opts[:offset]

          {
            :start_key  => start,
            :offset_key => offset,
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
          get_cell(id, column_family_name, column_name).try :value
        end

        #
        # Fast way of fetching one cell
        #
        def get_cell(id, column_family_name, column_name)
          if cell = connection.get(name, id, "#{column_family_name.to_s}:#{column_name.to_s}", {}).first
            MassiveRecord::Wrapper::Cell.populate_from_tcell(cell)
          end
        end
        
        #
        # Finds one or multiple ids
        #
        # Returns nil if id is not found
        #
        def find(*args)
          return nil unless exists?

          options = args.extract_options!.symbolize_keys
          what_to_find = args.first
          
          if column_families_to_find = options[:select]
            column_families_to_find = column_families_to_find.collect { |c| c.to_s }
          end

          if what_to_find.is_a?(Array)
            connection.getRowsWithColumns(name, what_to_find, column_families_to_find, {}).collect do |t_row_result|
              Row.populate_from_trow_result(t_row_result, connection, name, column_families_to_find)
            end
          else
            if t_row_result = connection.getRowWithColumns(name, what_to_find, column_families_to_find, {}).first
              Row.populate_from_trow_result(t_row_result, connection, name, column_families_to_find)
            end
          end
        end

        def find_in_batches(opts = {})
          # puts "find_in_batches called #{opts} name=#{name}"
          # puts "find_in_batches connection #{connection}"
          # puts "find_in_batches connection.tables #{connection.tables}"
          # puts "find_in_batches connection.tables.include?(name) = #{connection.tables.include?(name)}"
          # puts "find_in_batches is exists"
          return nil unless exists
          results_limit = opts[:limit]
          results_found = 0
          
          rr = scanner(opts) do |s|
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
          connection.close

          rr
        end
    
        def exists
          @table_exists = connection.tables.include?(name)
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
