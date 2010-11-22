module MassiveRecord
  
  class Scanner
    
    attr_accessor :connection, :table_name, :column_family_names, :start_key, :opened_scanner
    
    def initialize(connection, table_name, column_family_names, start_key = "")
      @connection = connection
      @table_name = table_name
      @column_family_names = column_family_names.collect{|n| "#{n.split(":").first}:"}
      @start_key = start_key
    end
    
    def client
      connection.client
    end
    
    def open
      begin
        @opened_scanner ||= client.scannerOpen(table_name, start_key, column_family_names)
        true
      rescue => e
        false
      end
    end
    
    def fetch_trows(opts = {})
      opts[:limit] ||= 10
      client.scannerGetList(opened_scanner, opts[:limit])
    end
    
    def fetch_rows(opts = {})
      populate_rows(fetch_trows(opts))
    end
    
    def populate_rows(results)
      results.collect{|result| populate_row(result)}
    end
    
    def populate_row(result)
      Row.populate_from_t_row_result(result, connection, table_name)
    end
    
  end
  
end