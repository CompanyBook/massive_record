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




            def row_for_record(record)
              raise IdMissing.new("You must set an ID before save.") if record.id.blank?

              MassiveRecord::Wrapper::Row.new({
                :id => record.id,
                :table => record.class.table
              })
            end

            def update_only_record_in_embedded_collection(relation_proxy_for_target)
              inverse_of_proxy = relation_proxy_for_target.load_proxy_target.send(
                :relation_proxy, relation_proxy_for_target.metadata.inverse_of
              )
              
              row = row_for_record(relation_proxy_for_target)
              row.values = {
                inverse_of_proxy.metadata.store_in => {
                  record.id => Base.coder.dump(record.attributes_db_raw_data_hash)
                }
              }

              row.save
            end
          end
        end
      end
    end
  end
end
