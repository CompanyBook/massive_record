module MassiveRecord
  module ORM
    class ColumnFamily
      
      attr_reader :name, :autoload
      
      def initialize(name, &block)
        @fields = []
        @name = name
        @autoload = false
        instance_eval &block
      end
      
      def field(*args)
        f = Field.new(*args)
        f.column_family = @name
        @fields.push(f)
      end
      
      def fields
        @fields.inject(Fields.new){|h, (field)| h[field.name.to_s] = field; h}
      end
      
      def autoload(*args)
        @autoload = true
      end
      
      def autoload?
        @autoload
      end
      
      def populate_fields_from_row_columns(columns)
        columns.each do |n, c|
          field(n.split(':')[1]) if n.split(':')[0] == @name.to_s
        end
      end
      
    end
  end
end