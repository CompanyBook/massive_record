module MassiveRecord
  module Wrapper
    class TablesCollection < Array
    
      attr_accessor :connection
    
      def load(table_name)
        ADAPTER::Table.new(connection, table_name)
      end
    
    end
  end
end