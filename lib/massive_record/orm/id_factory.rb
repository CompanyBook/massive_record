require 'singleton'

module MassiveRecord
  module ORM
    module IdFactory
      extend ActiveSupport::Concern

      included do
        include Singleton
      end

      module ClassMethods
        #
        # Delegates to the instance, just a shout cut.
        #
        def next_for(table)
          instance.next_for(table)
        end
      end

      #
      # Returns a new and unique id for a given table name
      # Table can a symbol, string or an object responding to table_name
      #
      def next_for(table)
        table = table.respond_to?(:table_name) ? table.table_name : table.to_s
        next_id :table => table
      end


      private

      #
      # Methods which generates next id, will receive at least
      # :table => 'name' as options
      #
      def next_id(options = {})
        raise "Needs implementation :-)"
      end
    end
  end
end

require 'massive_record/orm/id_factory/atomic_incrementation'
require 'massive_record/orm/id_factory/timestamp'

ActiveSupport.on_load(:massive_record) do
  MassiveRecord::ORM::Base.id_factory = MassiveRecord::ORM::IdFactory::AtomicIncrementation
  MassiveRecord::ORM::Embedded.id_factory = MassiveRecord::ORM::IdFactory::Timestamp
end
