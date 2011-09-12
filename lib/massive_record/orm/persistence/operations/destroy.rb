require 'massive_record/orm/persistence/operations/table_operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        class Destroy
          include Operations, TableOperationHelpers

          def execute
            row_for_record.destroy
          end
        end
      end
    end
  end
end
