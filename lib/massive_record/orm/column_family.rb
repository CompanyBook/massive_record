module MassiveRecord
  module ORM
    module ColumnFamily
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        
        @@column_families = []
        
        def column_families
          @@column_families
        end
        
        def column_family(*args, &block)
          @@column_families.push(args[0])
        end
        
      end
      
    end
  end
end