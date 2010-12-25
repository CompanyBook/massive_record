require 'massive_record/orm/schema/table_interface'

module MassiveRecord
  module ORM
    class Table < Base
      include MassiveRecord::ORM::Schema::TableInterface
      
      class_attribute :column_families, :instance_writer => false
      self.column_families = []

      class_attribute :autoloaded_column_family_names, :instance_writer => false
      self.autoloaded_column_family_names = []

      def self.column_family(*args, &block)
        column_family = ColumnFamily.new(args[0], &block)
        self.autoloaded_column_family_names += [column_family.name] if column_family.autoload?
        self.column_families += [column_family]
        self.attributes_schema = self.attributes_schema.merge(column_family.fields)
        
        # FIXME
        self.autoloaded_column_family_names = self.autoloaded_column_family_names.uniq
      end
    end
  end
end
