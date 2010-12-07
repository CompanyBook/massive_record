module MassiveRecord
  module ORM
    class Table < Base
      
      def initialize(*)
        super
        @attributes_schema = {}
        column_families.each{|cf| @attributes_schema = @attributes_schema.merge(cf.fields)}
      end
      
      @@column_families = {}
      
      def self.column_families
        @@column_families[to_s]
      end
      
      def self.column_family(*args, &block)
        @@column_families[to_s] ||= []
        @@column_families[to_s].push(ColumnFamily.new(args[0], &block))
      end
      
      def column_families
        self.class.column_families
      end

    end
  end
end
