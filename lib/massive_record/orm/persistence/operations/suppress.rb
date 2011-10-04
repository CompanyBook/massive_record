module MassiveRecord
  module ORM
    module Persistence
      module Operations
        class Suppress
          include Operations

          def execute
            true
          end
        end
      end
    end
  end
end
