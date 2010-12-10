module MassiveRecord
  module ORM
    class Table < Base
      
      class_attribute :column_families, :instance_writer => false
      self.column_families = []

      class_attribute :autoloaded_column_family_names, :instance_writer => false
      self.autoloaded_column_family_names = []

      # TODO / FIXME?
      #   I'm not sure if I think its a god idea to maintain two variables
      #   (column_families and attributes_schema) which is two sides of the
      #   same coin. maybe attributes_schema should be a method on column family
      #   object instead, and if needed cache that value. If we later decide to
      #   implement a functionality for deleting a column family we should only
      #   need to maintain one "master" variable, instead of two like we need now.
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
