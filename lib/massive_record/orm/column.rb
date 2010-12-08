module MassiveRecord
  module ORM
    class Column < Base
      
      def default_attributes_from_schema
        Hash.new
      end
      
    end
  end
end
