module MassiveRecord
  module Adapters
    module Thrift
      class Row
    
        attr_accessor :id, :column_families, :columns, :new_record, :table
    
        def initialize(opts = {})
          @id              = opts[:id]
          self.values      = opts[:values] || {}
          @table           = opts[:table]
          @column_families = opts[:column_families] || []
          @columns         = opts[:columns] || {}
          @new_record      = true
        end
      
        def column_names
          columns.keys
        end
    
        def fetch_all_column_families
          @table.fetch_column_family
          fetch_column_families(@table.column_family_names)
        end
    
        def fetch_column_families(list)
          @column_families = table.column_families.collect do |column_name, description|
             MassiveRecord::Wrapper::ColumnFamily.new(column_name.split(":").first, {
              :row          => self,
              :name         => description.name,
              :max_versions => description.maxVersions,
              :compression  => description.compression,
              :in_memory    => description.inMemory
              # bloomFilterType, bloomFilterVectorSize, bloomFilterNbHashes, blockCacheEnabled, timeToLive
            })
          end
        end
    
        # = Parse columns / cells and create a Hash from them
        def values
          @columns.inject({"id" => id}) {|h, (column_name, cell)| h[column_name] = cell.value; h}
        end

        # Returns values as a nested hash.
        #
        # {
        #   'family' => {
        #     'attr1' => 'value'
        #     'attr2' => 'value'
        #   },
        #   ...
        # }
        #
        # I think maybe that values should return this instead, as it is what the
        # values= expects to receive.
        def values_hash
          Hash.new { |hash, key| hash[key] = {} }.tap do |hash|
            @columns.each do |key, column|
              column_family, name = key.split(':')
              hash[column_family][name] = column.value
            end
          end
        end

        def values=(data)
          @values = {}
          update_columns(data)
        end
    
        def update_columns(data = {})
          data.each do |column_family_name, columns|
            columns.each do |column_name, values|
              update_column(column_family_name, column_name, values)
            end
          end
        end
    
        def update_column(column_family_name, column_name, value)
          column = "#{column_family_name}:#{column_name}"
      
          if @columns[column].nil?
            @columns[column] =  MassiveRecord::Wrapper::Cell.new({:value =>  value, :created_at => Time.now})
          else
            @columns[column].value = value
          end
        end
    
        # = Parse columns cells and save them
        def save
          mutations = []
      
          @columns.each do |column_name, cell|
            mutations << Apache::Hadoop::Hbase::Thrift::Mutation.new(:column => column_name).tap do |mutation|
              if new_value = cell.value_to_thrift
                mutation.value = new_value
              else
                mutation.isDelete = true
              end
            end
          end

          @table.client.mutateRow(@table.name, id.to_s.dup.force_encoding(Encoding::BINARY), mutations).nil?
        end


        
        def atomic_increment(column_name, by = 1)
          @table.client.atomicIncrement(@table.name, id.to_s, column_name, by) 
        end

        def atomic_decrement(column_name, by = 1)
          atomic_increment(column_name, -by)
        end
        
        def read_atomic_integer_value(column_name)
          atomic_increment(column_name, 0)
        end
    
        def self.populate_from_trow_result(result, connection, table_name, column_families = [])
          row                 = self.new
          row.id              = result.row
          row.new_record      = false
          row.table           = Table.new(connection, table_name)
          row.column_families = column_families

          result.columns.each do |name, value|
            row.columns[name] =  MassiveRecord::Wrapper::Cell.new({
              :value      => value.value,
              :created_at => Time.at(value.timestamp / 1000, (value.timestamp % 1000) * 1000)
            })
          end
      
          row
        end
    
        def destroy
          @table.client.deleteAllRow(@table.name, @id).nil?
        end
    
        def new_record?
          @new_record
        end
    
        def prev
          self
        end
    
        def updated_at
          columns.values.collect(&:created_at).max
        end
        
      end
    end  
  end
end
