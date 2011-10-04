require 'massive_record/orm/persistence/operations/embedded/operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module Embedded
          class Update
            include Operations, OperationHelpers

            def execute
              raise_error_if_embedded_in_proxy_targets_are_missing
              update_only_embedded_record_in_owners
            end


            private

            def update_only_embedded_record_in_owners
              embedded_in_proxies.select { |p| p.load_proxy_target.present? }.each do |proxy|
                update_embedded(proxy, Base.coder.dump(record.attributes_db_raw_data_hash))
              end
            end
          end
        end
      end
    end
  end
end
