require 'massive_record/orm/persistence/operations/embedded/operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module Embedded
          class Destroy
            include Operations, OperationHelpers

            def execute
              embedded_in_proxies.each do |proxy|
                if proxy.load_proxy_target && proxy.load_proxy_target.persisted?
                  inverse_proxy_for(proxy).delete(record)
                  update_embedded(proxy, nil)
                end
              end

              true
            end
          end
        end
      end
    end
  end
end
