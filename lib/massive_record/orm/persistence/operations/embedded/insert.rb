module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module Embedded
          class Insert
            include Operations

            def execute
              raise_error_if_embedded_in_proxy_targets_are_missing
            end


            private

            def embedded_in_proxies
              record.relation_proxies.select { |proxy| proxy.metadata.embedded_in? }
            end

            def raise_error_if_embedded_in_proxy_targets_are_missing
              relations_not_assigned = embedded_in_proxies.collect do |proxy|
                proxy.metadata.name if proxy.load_proxy_target.nil? 
              end.compact

              if relations_not_assigned.any?
                raise MassiveRecord::ORM::NotAssignedToEmbeddedCollection.new(record, relations_not_assigned)
              end
            end
          end
        end
      end
    end
  end
end
