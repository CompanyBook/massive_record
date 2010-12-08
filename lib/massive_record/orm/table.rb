module MassiveRecord
  module ORM
    class Table < Base
      
      def initialize(*)
        @attributes_schema = {}
        column_families.each{|cf| @attributes_schema = @attributes_schema.merge(cf.fields)}
        super
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
      
      def default_attributes_from_schema
        h = {}
        @attributes_schema.each do |k, v|
          h[v.name] = v.default
        end
        h
      end
      
    end
  end
end
