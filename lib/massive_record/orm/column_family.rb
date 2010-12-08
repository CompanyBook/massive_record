module MassiveRecord
  module ORM
    class ColumnFamily
      
      attr_reader :name
      
      def initialize(name, &block)
        @fields = []
        @name = name
        instance_eval &block
      end
      
      def field(*args)
        f = Field.new(*args)
        f.column_family = @name
        @fields.push(f)
      end
      
      def fields
        @fields.inject(Fields.new){|h, (field)| h[field.unique_name] = field; h}
      end
      
    end
  end
end