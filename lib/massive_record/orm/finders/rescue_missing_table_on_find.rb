module MassiveRecord
  module ORM
    #
    # Module which adds functionality so we rescue errors which might occur on
    # find calls when we are querying tables which does not exist.
    # Small problem with this, which will need to look into.
    #
    module RescueMissingTableOnFind
      def do_find(*args)
        create_table_and_retry_if_table_missing { super }
      end

      def find_in_batches(*args) 
        create_table_and_retry_if_table_missing { super }
      end



      private


      #
      # Yields the block and if any errors occur we will check if table does exist or not.
      # Create it if it's missing and try again.
      #
      # Errors which we'll retry on are:
      #   Apache::Hadoop::Hbase::Thrift::IOError          -> Raised on simple find(id) calls
      #   Apache::Hadoop::Hbase::Thrift::IllegalArgument  -> Raised when a scanner is used
      #
      def create_table_and_retry_if_table_missing # :nodoc:
        begin
          yield
        rescue Apache::Hadoop::Hbase::Thrift::IOError, Apache::Hadoop::Hbase::Thrift::IllegalArgument => error
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
