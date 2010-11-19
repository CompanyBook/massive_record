module MassiveRecord
  
  class ColumnFamiliesCollection < Array
    
    attr_accessor :table
    
    def create(column_family, opts = {})
      if column_family.is_a?(MassiveRecord::ColumnFamily)
        self.push(column_family)
      else
        self.push(MassiveRecord::ColumnFamily.new(column_family, opts))
      end
      
      true
    end
    
  end
  
end