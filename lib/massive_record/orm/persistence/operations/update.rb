require 'massive_record/orm/persistence/operations/table_operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        class Update
          include Operations, TableOperationHelpers

          def execute
            ensure_that_we_have_table_and_column_families!
            store_record_to_database('update', attribute_names_to_update)
          end


          private

          def attribute_names_to_update
            options[:attribute_names_to_update] || []
          end
        end
      end
    end
  end
end
