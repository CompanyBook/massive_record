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
              if record.persisted?
                if embedded_in_proxies.compact.length == 1
                  embeds_many_proxy_currently_embedded_in = inverse_proxy_for(embedded_in_proxies.first)
                  embeds_many_proxy_currently_embedded_in.reload
                  embeds_many_proxy_currently_embedded_in.find(record.id).tap do |reloaded_record|
                    record.reinit_with({
                      'attributes' => reloaded_record.attributes,
                      'raw_data' => reloaded_record.raw_data
                    })
                  end
                else
                  raise UnsupportedNumberOfEmbeddedIn.new(<<-TXT
                    Found '#{embedded_in_proxies.length}' embedded_in relations in #{klass}. We currently only support reload when embedded in '1' record
                  TXT
                  )
                end

                true
              end
            end
          end
        end
      end
    end
  end
end
