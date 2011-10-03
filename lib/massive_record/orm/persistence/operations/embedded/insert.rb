require 'massive_record/orm/persistence/operations/embedded/operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module Embedded
          class Insert
            include Operations, OperationHelpers

            def execute
              raise_error_if_embedded_in_proxy_targets_are_missing

              # NOTE
              #
              # When / if we allow for auto-save false when assigning
              # an embedded record to an embeds many collection we might
              # want to only update current insert in the targets, not a
              # complete save of the parent.
              embedded_in_proxy_targets.collect(&:save).any?
            end
          end
        end
      end
    end
  end
end
