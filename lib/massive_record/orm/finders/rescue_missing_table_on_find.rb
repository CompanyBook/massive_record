module MassiveRecord
  module ORM
    module RescueMissingTableOnFind
      def do_find(*args)
        create_table_and_retry_if_table_missing { super }
      end

      def find_in_batches(*args) 
        create_table_and_retry_if_table_missing { super }
      end



      private


      def create_table_and_retry_if_table_missing
        begin
          yield
        rescue Apache::Hadoop::Hbase::Thrift::IOError => error
          if table.exists?
            raise error
          else
            logger.try :info, "*** TABLE MISSING: Table '#{table_name}' seems to be missing. Will create it, then retry call to find()."
            hbase_create_table!
            yield
          end
        end
      end
    end
  end
end
