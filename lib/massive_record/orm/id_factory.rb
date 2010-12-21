require 'singleton'

module MassiveRecord
  module ORM
    class IdFactory < Table
      include Singleton

      COLUMN_FAMILY_FOR_TABLES = :tables
      ID = "id_factory"

      column_family COLUMN_FAMILY_FOR_TABLES do
        autoload
      end


      def self.instance
        if table_exists?
          @instance = find(ID) rescue new
        else
          @instance = new
        end
      end

      #
      # Returns a new and unique id for a given table name
      # Table can a symbol, string or an object responding to table_name
      #
      def next_for(table)
        table = table.respond_to?(:table_name) ? table.table_name : table.to_s
        next_id :table => table
      end



      def id
        ID
      end

      private

      #
      # Method which actually does the increment work for
      # a given table name as string
      #
      def next_id(options = {}) 
        options.assert_valid_keys(:table)
        table_name = options.delete :table

        create_field_or_ensure_type_integer_for(table_name)
        increment!(table_name)

        self[table_name]
      end




      def create_field_or_ensure_type_integer_for(table_name)
        if has_field_for? table_name
          ensure_type_integer_for(table_name)
        else
          create_field_for(table_name)
        end
      end


      #
      # Creates a field for a table name which is new
      # Feels a bit hackish, hooking in and doing some of what the
      # autoload-functionality of column_family block above does too.
      # But at least, we can "dynamicly" assign new attributes to this object.
      # 
      # TODO  Maybe something the ORM should provide instead and put them in a default
      #       column-family?
      #
      def create_field_for(table_name)
        column_family_for_tables.field(table_name, :integer)
        self.class.attributes_schema = self.class.attributes_schema.merge(column_family_for_tables.fields)
        @attributes[table_name.to_s] = nil
        self.class.undefine_attribute_methods
      end
      
      #
      # Just makes sure that definition of a field is set to integer.
      # This is needed as the autoload functionlaity sets all types to strings.
      #
      def ensure_type_integer_for(table_name)
        column_family_for_tables.fields[table_name].type = :integer
      end


      def has_field_for?(table_name)
        respond_to? table_name
      end

      def column_family_for_tables
        @column_family_for_tables ||= column_families.detect { |c| c.name == COLUMN_FAMILY_FOR_TABLES }
      end
    end
  end
end
