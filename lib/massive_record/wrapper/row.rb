require 'json'

module MassiveRecord
  module Wrapper  
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

      def fetch_all_column_families
        @table.fetch_column_family
        fetch_column_families(@table.column_family_names)
      end
    
      def fetch_column_families(list)
        @column_families = table.column_families.collect do |column_name, description|
          ColumnFamily.new(column_name.split(":").first, {
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
        @columns.inject({"id" => id}) {|h, (column_name, cell)| h[column_name] = cell.deserialize_value; h}
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
          @columns[column] = Cell.new({ :value => Cell.serialize_value(value), :created_at => Time.now })
        else
          @columns[column].serialize_value(value)
        end
      end
    
      # = Merge column values with new data : it implies that column values is a JSON encoded string
      def merge_columns(data)
        data.each do |column_family_name, columns|
          columns.each do |column_name, values|
            if values.is_a?(Hash)
              unless @columns["#{column_family_name}:#{column_name}"].nil?
                column_value = @columns["#{column_family_name}:#{column_name}"].deserialize_value.merge(values)
              else
                column_value = values
              end            
            elsif values.is_a?(Array)
              unless @columns["#{column_family_name}:#{column_name}"].nil?
                column_value = @columns["#{column_family_name}:#{column_name}"].deserialize_value | values
              else
                column_value = values
              end            
            else
              column_value = values
            end
            update_column(column_family_name, column_name, column_value)
          end
        end
      end
    
      # = Parse columns cells and save them
      def save
        mutations = []
      
        @columns.each do |column_name, cell|
          m        = Apache::Hadoop::Hbase::Thrift::Mutation.new
          m.column = column_name
          m.value  = cell.serialized_value
        
          mutations.push(m)
        end
      
        @table.client.mutateRow(@table.name, id.to_s, mutations).nil?
      end    
    
      def self.populate_from_t_row_result(result, connection, table_name, column_families = [])
        row                 = self.new
        row.id              = result.row
        row.new_record      = false
        row.table           = Table.new(connection, table_name)
        row.column_families = column_families

        result.columns.each do |name, value|
          row.columns[name] = Cell.new({
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
    
    end  
  end
end
