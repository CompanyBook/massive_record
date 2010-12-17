module MassiveRecord
  module Wrapper
    class Scanner
    
      attr_accessor :connection, :table_name, :column_family_names, :start_key, :created_at, :opened_scanner
      attr_accessor :formatted_column_family_names, :column_family_names
      
      def initialize(connection, table_name, column_family_names, opts = {})
        @connection = connection
        @table_name = table_name
        @column_family_names = column_family_names.collect{|n| n.split(":").first}
        @formatted_column_family_names = column_family_names.collect{|n| "#{n.split(":").first}:"}
        @start_key = opts[:start_key]
        @created_at = opts[:created_at]
      end
    
      def client
        connection
      end
    
      def open
        begin
          if created_at.to_s.empty?
            @opened_scanner ||= client.scannerOpen(table_name, start_key, formatted_column_family_names)
          else
            @opened_scanner ||= client.scannerOpenTs(table_name, start_key, formatted_column_family_names, created_at)
          end
          true
        rescue => e
          false
        end
      end
    
      def fetch_trows(opts = {})
        opts[:limit] ||= 10
      
        #client.scannerGet(@start_key)
        open
        client.scannerGetList(opened_scanner, opts[:limit])
      end
    
      def fetch_rows(opts = {})
        populate_rows(fetch_trows(opts))
      end
    
      def populate_rows(results)
        results.collect{|result| populate_row(result)}
      end
    
      def populate_row(result)
        Row.populate_from_t_row_result(result, connection, table_name, column_family_names)
      end
    
    end
  end
end