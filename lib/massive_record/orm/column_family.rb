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
      
      def autoload
        @autoload = true
      end
      
    end
  end
end