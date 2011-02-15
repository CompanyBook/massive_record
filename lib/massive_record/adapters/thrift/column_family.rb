module MassiveRecord
  module Adapters
    module Thrift
      class ColumnFamily
      
        attr_accessor :name, :max_versions, :columns
    
        def initialize(column_name, opts = {})
          @name = column_name
          @max_versions = opts[:max_versions] || 10
          @columns = opts[:columns] || []
        end
    
        def descriptor
          Apache::Hadoop::Hbase::Thrift::ColumnDescriptor.new do |col|
            col.name = "#{name}:"
            col.maxVersions = max_versions
          end
        end
    
      end
    end
  end
end