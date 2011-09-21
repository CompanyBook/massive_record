module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class EmbedsMany < Proxy
          #
          # Returns the raw hash of attributes for embedded objects
          #
          def proxy_targets_raw # :nodoc:
            proxy_owner.raw_data[metadata.store_in]
          end

          #
          # Returns a hash with ids and serialized version
          # of embedded object which should be updated. The value
          # will be nil if it is supposed to be destroyed.
          #
          # # TODO refactor this out maybe, it kinda does not belong here..
          #
          def proxy_targets_update_hash # :nodoc:
            Hash[proxy_target.collect do |record|
              if record.destroyed?
                [record.id, nil]
              elsif record.new_record? || record.changed?
                [record.id, Base.coder.dump(record.attributes_db_raw_data_hash)]
              end
            end.compact]
          end

          #
          # Call this when parent is saved. Will change state of proxy
          # targets so that:
          #
          # * New records are marked as persisted.
          # * Dirty changes are being reset.
          # * Destroyed records are being wiped.
          #
          # ..but the way it is done now is bad, cos it is hooking
          # into internals of the classes.
          #
          # What would be really cool is to have some kind of delayed save
          # we can use in the push / << / concat method. We want to push
          # multiple records in before save, but at the same time we want to
          # call save on each pushed records to get them to do their internal
          # state logic. So something like
          #
          # with_delayed_save do
          #   # pushing and save each record here
          #   # embedded_record.save calls are delayed
          #   #
          #   # After block to method is yielded
          #   # we do the actually proxy_owner.save
          # end
          #
          def parent_has_been_saved! # :nodoc:
            proxy_target.each do |record|
              record.instance_variable_set(:@new_record, false) if record.new_record?
              record.send(:clear_dirty_states!) if record.changed?
            end
          end

          def changed?
            proxy_target.any? do |record|
              record.new_record? || record.destroyed? || record.changed?
            end
          end

          def changes
            Hash[proxy_target.collect do |record|
              if record.changed?
                [record.id, record.changes]
              end
            end.compact]
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
                unless include? record
                  proxy_target << record
                end
              end

              proxy_owner.save if proxy_owner.persisted?

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
            id, raw_data = proxy_targets_raw.first

            proxy_targets_raw.inject([]) do |records, (id, raw_data)|
              attributes_and_raw_data = proxy_target_class.transpose_raw_data_to_record_attributes_and_raw_data(id, raw_data)
              records << proxy_target_class.send(:instantiate, *attributes_and_raw_data)
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
