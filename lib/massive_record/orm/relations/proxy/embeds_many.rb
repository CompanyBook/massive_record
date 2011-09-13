module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class EmbedsMany < Proxy
          def initialize(options = {})
            super
          end


          #
          # Returns the raw hash of attributes for embedded objects
          #
          def proxy_targets_raw # :nodoc:
            proxy_owner.raw_data[metadata.store_in]
          end


          # FIXME Common to all proxies representing multiple values
          def load_proxy_target(options = {})
            proxy_target_before_load = proxy_target
            proxy_target_after_load = super

            self.proxy_target = (proxy_target_before_load + proxy_target_after_load).uniq
          end




          def find(id)
            raise "TODO" # TODO
          end

          def limit(limit)
            raise "TODO" # TODO
          end



          def reset
            super
            @proxy_target = []
          end

          def replace(*records)
            records.flatten!

            if records.length == 1 and records.first.nil?
              reset
            else
              delete_all
              concat(records)
            end
          end


          #
          # Adding record(s) to the collection.
          #
          def <<(*records)
            records.flatten!

            if records.all? &:valid?
              records.each do |record|
                proxy_target << record
              end

              self
            end
          end
          alias_method :push, :<<
          alias_method :concat, :<<

          #
          # Destroy record(s) from the collection
          # Each record will be asked to destroy itself as well
          #
          def destroy(*records)
            delete_or_destroy *records, :destroy
          end


          #
          # Deletes record(s) from the collection
          #
          def delete(*records)
            delete_or_destroy *records, :delete
          end

          #
          # Destroys all records
          #
          def destroy_all
            destroy(load_proxy_target)
            reset
            loaded!
          end

          #
          # Deletes all records from the relationship.
          # Does not destroy the records
          #
          def delete_all
            delete(load_proxy_target)
            reset
            loaded!
          end

          #
          # Checks if record is included in collection
          #
          def include?(record)
            load_proxy_target.include? record
          end

          def length
            load_proxy_target.length
          end
          alias_method :count, :length
          alias_method :size, :length

          def empty?
            length == 0
          end

          def first
            limit(1).first
          end




          private

          def find_proxy_target(options = {})
            proxy_targets_raw.inject([]) do |records, (id, attributes)|
              records << proxy_target_class.send(:instantiate, attributes, {})
            end
          end

          # FIXME Common to all proxies representing multiple values
          def find_proxy_target_with_proc(options = {}, &block)
            Array(super).compact
          end

          def delete_or_destroy(*records, method)
          end

          def can_find_proxy_target?
            super || proxy_targets_raw.any?
          end
        end
      end
    end
  end
end
