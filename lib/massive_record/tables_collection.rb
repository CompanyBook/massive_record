module MassiveRecord
  
  class TablesCollection < Array
    
    attr_accessor :connection
    
    def load(table_name)
      Table.new(connection, table_name)
    end
    
  end
  
end