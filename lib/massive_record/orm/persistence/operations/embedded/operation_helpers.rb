module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module Embedded
          module OperationHelpers
            def embedded_in_proxies
              record.relation_proxies.select { |proxy| proxy.metadata.embedded_in? }
            end
            
            def embedded_in_proxy_targets
              embedded_in_proxies.collect(&:load_proxy_target)
            end

            def raise_error_if_embedded_in_proxy_targets_are_missing
              relations_not_assigned = embedded_in_proxies.collect do |proxy|
                proxy.metadata.name if proxy.load_proxy_target.nil? 
              end.compact

              if relations_not_assigned.any?
                raise MassiveRecord::ORM::NotAssignedToEmbeddedCollection.new(record, relations_not_assigned)
              end
            end

            def update_embedded(relation_proxy, value)
              row = row_for_record(relation_proxy)
              row.values = {
                inverse_proxy_for(relation_proxy).metadata.store_in => {
                  record.id => value
                }
              }
              row.save
            end






            def inverse_proxy_for(proxy)
              proxy.load_proxy_target.send(:relation_proxy, proxy.metadata.inverse_of)
            end


            def row_for_record(record)
              raise IdMissing.new("You must set an ID before save.") if record.id.blank?

              MassiveRecord::Wrapper::Row.new({
                :id => record.id,
                :table => record.class.table
              })
            end

          end
        end
      end
    end
  end
end
