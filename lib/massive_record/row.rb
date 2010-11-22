module MassiveRecord
    
  class Row
    
    attr_writer :table
    
    attr_accessor :id, :column_families, :columns, :new_record
    
    def initialize(opts = {})
      @id              = opts[:id]
      self.values      = opts[:values] || {}
      @table           = opts[:table]
      @column_families = opts[:column_families] || []
      @columns         = opts[:columns] || []
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
      @values.empty? ? format_values : @values
    end
    
    def format_values
      @values = @columns.inject({"id" => id}) {|h, (column)| h[column.name] = column.cells.first.value; h}
    end
    
    def values=(data)
      @values = {}
      update_values(data)
    end
        
    def parse_values(data)
      update_values(data)
    end
    
    def update_values(data = {})
      data.each do |column_family_name, columns|
        columns.each do |column_name, values|
          update_value(column_family_name, column_name, values)
        end
      end
    end
    
    def update_value(column_family_name, column_name, value)
      @values["#{column_family_name}:#{column_name}"] = value
    end
    
    def merge_values(data)
      
    end
    
    # = Parse columns cells and save them
    def save
      mutations = []
      
      @values.each do |k, v|
        m        = Apache::Hadoop::Hbase::Thrift::Mutation.new
        m.column = k
        m.value  = serialize_value(v)
        
        mutations.push(m)
      end
      
      @table.client.mutateRow(@table.name, id, mutations).nil?
    end    
    
    def serialize_value(v)
      if v.is_a?(String)
        v
      elsif v.is_a?(Hash) || v.is_a?(Array)
        v.to_json
      end
    end
    
    def self.populate_from_t_row_result(result, connection, table_name)
      row                 = self.new
      row.id              = result.row
      row.new_record      = false
      row.table           = Table.new(connection, table_name)
      row.column_families = result.columns.keys.collect{|k| k.split(":").first}.uniq
      
      result.columns.each do |name, value|
        cell = Cell.new({
          :value      => value.value,
          :created_at => Time.at(value.timestamp / 1000, (value.timestamp % 1000) * 1000)
        })
        
        column = Column.new({
          :name  => name,
          :cells => [cell]
        })
        
        row.columns.push(column)
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
    
    def next
      self
    end
    
  end  

end