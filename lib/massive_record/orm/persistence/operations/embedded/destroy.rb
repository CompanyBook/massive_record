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
                update_embedded(proxy, nil) if proxy.load_proxy_target && proxy.load_proxy_target.persisted?
              end

              true
            end
          end
        end
      end
    end
  end
end
