require 'massive_record/orm/persistence/operations/embedded/operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module Embedded
          class Reload
            include Operations, OperationHelpers

            class UnsupportedNumberOfEmbeddedIn < MassiveRecordError; end

            def execute
              if record.persisted? && embeds_many_proxy_to_reload_from
                embeds_many_proxy_to_reload_from = inverse_proxy_for(embedded_in_proxies.first)
                embeds_many_proxy_to_reload_from.reload
                embeds_many_proxy_to_reload_from.find(record.id).tap do |reloaded_record|
                  record.reinit_with({
                    'attributes' => reloaded_record.attributes,
                    'raw_data' => reloaded_record.raw_data
                  })
                end

                true
              end
            end


            private

            def embeds_many_proxy_to_reload_from
              @embeds_many_proxy_to_reload_from ||= embedded_in_proxies.select { |p| p.load_proxy_target.present? }.first
            end
          end
        end
      end
    end
  end
end
