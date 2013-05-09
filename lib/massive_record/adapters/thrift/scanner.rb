module MassiveRecord
  module Adapters
    module Thrift
      class Scanner

        attr_accessor :connection, :table_name, :column_family_names, :opened_scanner
        attr_accessor :start_key, :stop_key, :start_prefix, :offset_key, :created_at, :limit
        attr_accessor :formatted_column_family_names, :column_family_names

        def initialize(connection, table_name, column_family_names, opts = {})
          @connection = connection
          @table_name = table_name
          @column_family_names = column_family_names.collect { |n| n.split(":").first }
          @column_family_names = opts[:columns] unless opts[:columns].nil?
          @formatted_column_family_names = @column_family_names.collect { |n| "#{n.split(":").first}:" }
          @start_key = opts[:start_key].to_s
          @stop_key = opts[:stop_key].to_s
          @start_prefix = opts[:start_prefix].to_s
          @offset_key = opts[:offset_key].to_s
          @created_at = opts[:created_at].to_s
          @limit = opts[:limit] || 10
        end

        def key
          offset_key.empty? ? start_key : offset_key
        end

        def open
          if !stop_key.empty?
            self.opened_scanner = connection.scannerOpenWithStop(table_name, start_key, stop_key, formatted_column_family_names)
          elsif !start_prefix.empty?
            self.opened_scanner = connection.scannerOpenWithPrefix(table_name, start_prefix, formatted_column_family_names)
          elsif created_at.empty?
            self.opened_scanner = connection.scannerOpen(table_name, key, formatted_column_family_names)
          else
            self.opened_scanner = connection.scannerOpenTs(table_name, key, formatted_column_family_names, created_at)
          end
        end

        def close
          begin
            connection.scannerClose(opened_scanner)
          rescue Apache::Hadoop::Hbase::Thrift::IllegalArgument => e
            #TODO log this
            raise e unless e.message =~ /scanner ID is invalid/
          end
        end

        def fetch_trows(opts = {})
          connection.scannerGetList(opened_scanner, limit)
        end

        def fetch_rows(opts = {})
          populate_rows(fetch_trows(opts))
        end

        def populate_rows(results)
          results.collect do |result|
            populate_row(result)
          end.select { |r| !r.nil? }
        end

        def populate_row(result)
          Row.populate_from_trow_result(result, connection, table_name, column_family_names)
        end

      end
    end
  end
end
