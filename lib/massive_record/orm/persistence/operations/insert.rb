require 'massive_record/orm/persistence/operations/table_operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        class Insert
          include Operations, TableOperationHelpers

          def execute
            klass.ensure_that_we_have_table_and_column_families!
            raise RecordNotUnique if klass.check_record_uniqueness_on_create && klass.exists?(record.id)
            store_record_to_database('create')
          end
        end
      end
    end
  end
end
