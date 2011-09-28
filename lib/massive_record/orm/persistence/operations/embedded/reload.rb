require 'massive_record/orm/persistence/operations/embedded/operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module Embedded
          class Reload
            include Operations, OperationHelpers

            def execute
              raise "NOT IMPLEMENTED YET!"
            end
          end
        end
      end
    end
  end
end
