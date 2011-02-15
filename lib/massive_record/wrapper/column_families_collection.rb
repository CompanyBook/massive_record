module MassiveRecord
  module Wrapper
    class ColumnFamiliesCollection < Array
  
      attr_accessor :table
  
      def create(column_family, opts = {})
        if column_family.is_a?(ADAPTER::ColumnFamily)
          self.push(column_family)
        else
          self.push(ADAPTER::ColumnFamily.new(column_family, opts))
        end
    
        true
      end
  
    end
  end
end