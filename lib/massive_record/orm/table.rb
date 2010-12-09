module MassiveRecord
  module ORM
    class Table < Base
      
      class_attribute :column_families, :instance_writer => false
      self.column_families = []

      def self.column_family(*args, &block)
        column_family = ColumnFamily.new(args[0], &block)
        self.column_families += [column_family]
        self.attributes_schema = self.attributes_schema.merge(column_family.fields)
      end
      
      def column_families
        self.class.column_families
      end
            
    end
  end
end
