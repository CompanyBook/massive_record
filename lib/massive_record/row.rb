module MassiveRecord
    
  class Row
    
    attr_writer :table, :values
    
    attr_accessor :id, :column_families, :columns
    
    def initialize(opts = {})
      @id             = opts[:id]
      @values          = opts[:values] || {}
      @table           = opts[:table]
      @column_families = opts[:column_families] || []
      @columns         = opts[:columns] || []
    end

    def fetch_all_column_families
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
      !@values.empty? ? @values : columns.inject({"id" => id}) {|h, (column)| h[column.name] = column.cells.first.value; h}
    end
    
    def parse_values(data)
      data.each do |column_family_name, columns|
        columns.each do |column_name, values|
           @values["#{column_family_name}:#{column_name}"] = values
        end
      end
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
    
    def self.populate_from_t_row_result(result)
      row                 = self.new
      row.id              = result.row
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
    
  end  

end