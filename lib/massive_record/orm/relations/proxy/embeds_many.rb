module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class EmbedsMany < ProxyCollection
          def find(id)
            record =  if loaded? || proxy_owner.new_record?
                        proxy_target.detect { |record| record.id == id }
                      else
                        find_one_embedded_record_from_raw_data(id)
                      end

            record or raise RecordNotFound.new("Could not find #{proxy_target_class.model_name} with id=#{id}")
          end

          def limit(limit)
            load_proxy_target.slice(0, limit)
          end


          #
          # Adding record(s) to the collection.
          #
          def <<(*records)
            records.flatten!

            if records.all? &:valid?
              records.each do |record|
                unless include? record
                  raise_if_type_mismatch(record)
                  proxy_target << record
                end
              end

              if proxy_owner.persisted?
                proxy_owner.save
              else
                proxy_target.sort_by! &:id
              end

              self
            end
          end
          alias_method :push, :<<
          alias_method :concat, :<<


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
            update_hash = proxy_target.collect do |record|
                            if record.destroyed?
                              [record.id, nil]
                            elsif record.new_record? || record.changed?
                              [record.id, Base.coder.dump(record.attributes_db_raw_data_hash)]
                            end
                          end

            update_hash |= to_be_destroyed.collect { |record| [record.id, nil] }

            Hash[update_hash.compact]
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
            reload_raw_data

            proxy_target.each do |record|
              record.instance_variable_set(:@new_record, false) if record.new_record?
              record.send(:clear_dirty_states!) if record.changed?
            end

            to_be_destroyed.each { |record| record.instance_variable_set(:@destroyed, true) }
            to_be_destroyed.clear
          end

          def changed?
            to_be_destroyed.any? || proxy_target.any? do |record|
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




          private

          def find_proxy_target(options = {})
            reload_raw_data if proxy_targets_raw.empty?

            proxy_targets_raw.inject([]) do |records, (id, raw_data)|
              records << instantiate_target_class(id, raw_data)
            end
          end

          #
          # Replaces the raw_data hash in parent with reloaded data from database
          #
          def reload_raw_data
            if proxy_owner.persisted?
              reloaded_data = proxy_owner.class.select(metadata.store_in).find(proxy_owner.id).raw_data[metadata.store_in]
              proxy_owner.update_raw_data_for_column_family(metadata.store_in, reloaded_data)
            end
          end


          def find_one_embedded_record_from_raw_data(id)
            raw_data = proxy_targets_raw[id] || load_raw_data_for_id(id)
            instantiate_target_class(id, raw_data) if raw_data
          end

          def load_raw_data_for_id(id)
            proxy_owner.class.table.get(proxy_owner.id, metadata.store_in, id)
          end

          # FIXME Common to all proxies representing multiple values
          def find_proxy_target_with_proc(options = {}, &block)
            Array(super).compact
          end

          def delete_or_destroy(*records, method)
            self.proxy_target -= records
            to_be_destroyed.concat(records).uniq!
            proxy_owner.save if proxy_owner.persisted? && method == :destroy
          end

          def can_find_proxy_target?
            true
          end


          def to_be_destroyed
            @to_be_destroyed ||= []
          end

          def instantiate_target_class(id, raw_data)
            proxy_target_class.send(:instantiate, *proxy_target_class.transpose_raw_data_to_record_attributes_and_raw_data(id, raw_data))
          end
        end
      end
    end
  end
end
