module MassiveRecord
  module ORM
    module RescueMissingTableOnFind
      def do_find(*args)
        begin
          super
        rescue Apache::Hadoop::Hbase::Thrift::IOError => error
          logger.info %{*** Table "#{table_name}" seems to be missing. Will create it, then call find() again}
          hbase_create_table! 
          super
        end
      end
    end
  end
end
