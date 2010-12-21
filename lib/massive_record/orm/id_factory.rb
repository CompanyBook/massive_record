require 'singleton'

module MassiveRecord
  module ORM
    class IdFactory < Table
      include Singleton

      def next_for(table)
        table = table.respond_to?(:table_name) ? table.table_name : table.to_s
        next_id :table => table
      end


      private


      def next_id(options = {})

      end
    end
  end
end
