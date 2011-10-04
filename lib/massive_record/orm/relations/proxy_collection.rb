module MassiveRecord
  module ORM
    module Relations

      #
      # Proxy class for relations representing a collection
      #
      class ProxyCollection < Proxy
        #
        # Loading proxy_targets will merge it with records found currently in proxy,
        # to make sure we don't remove any pushed proxy_targets only cause we load the
        # proxy_targets.
        #
        def load_proxy_target(options = {})
          proxy_target_before_load = proxy_target
          proxy_target_after_load = super

          self.proxy_target = (proxy_target_before_load + proxy_target_after_load).uniq
        end

        def reset(force = false)
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

        def first
          limit(1).first
        end

        def empty?
          length == 0
        end

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
      end
    end
  end
end
