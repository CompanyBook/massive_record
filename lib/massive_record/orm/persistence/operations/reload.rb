require 'massive_record/orm/persistence/operations/table_operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        class Reload
          include Operations, TableOperationHelpers

          def execute
            if record.persisted?
              klass.find(record.id).tap do |reloaded_record|
                record.reinit_with({
                  'attributes' => reloaded_record.attributes,
                  'raw_data' => reloaded_record.raw_data
                })
              end

              true
            end
          end
        end
      end
    end
  end
end
