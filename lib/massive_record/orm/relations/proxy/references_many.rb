module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesMany < Proxy
          #
          # Loading proxy_targets will merge it with records found currently in proxy,
          # to make sure we don't remove any pushed proxy_targets only cause we load the
          # proxy_targets.
          #
          # TODO  - Implement methods like:
          #         * find_in_batches
          #         * find_each
          #         * etc :-)
          #
          #       - A counter cache is also nice.
          #
          def load_proxy_target
            proxy_target_before_load = proxy_target
            proxy_target_after_load = super

            self.proxy_target = (proxy_target_before_load + proxy_target_after_load).uniq
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
            save_records = proxy_owner.persisted?

            if records.flatten.all? &:valid?
              records.flatten.each do |record|
                unless include? record
                  raise_if_type_mismatch(record)
                  add_foreign_key_in_proxy_owner(record.id)
                  proxy_target << record
                  record.save if save_records
                end
              end

              proxy_owner.save if save_records

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
          # TODO  This needs a bit of work, depending on if proxy's proxy_target
          #       has been loaded or not. For now, we are just checking
          #       what we currently have in @proxy_target
          #
          def include?(record)
            load_proxy_target.include? record
          end

          #
          # Returns the length of targes
          #
          # TODO  This can be smarter as well. For instance; if we have not
          #       loaded targets, and we have foreign keys in the owner we
          #       can simply do a owner's foreign keys and ask for it's length.
          #
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

          def find(id)
            if loaded?
              record = proxy_target.find { |record| record.id == id }
            elsif find_with_proc?
              if id.starts_with? proxy_owner.send(metadata.records_starts_from)
                record = proxy_target_class.find(id)
              end
            elsif foreign_key_in_proxy_owner_exists?(id)
              record = proxy_target_class.find(id)
            end

            raise RecordNotFound.new("Could not find #{proxy_target_class.model_name} with id=#{id}") if record.nil?

            record
          end

          #
          # Returns a limited result set of target records.
          #
          # TODO  If we know all our foreign keys (basically we also know our length)
          #       we can then mark our self as loaded if limit is equal to or greater
          #       than foreign keys length.
          #
          def limit(limit)
            if loaded?
              proxy_target.slice(0, limit)
            elsif find_with_proc?
              find_proxy_target_with_proc(:limit => limit)
            else
              ids = proxy_owner.send(metadata.foreign_key).slice(0, limit)
              ids = ids.first if ids.length == 1
              [find_proxy_target(ids)].flatten
            end
          end



          private


          def delete_or_destroy(*records, method)
            records.flatten.each do |record|
              if include? record
                remove_foreign_key_in_proxy_owner(record.id)
                proxy_target.delete(record)
                record.destroy if method.to_sym == :destroy
              end
            end

            proxy_owner.save if proxy_owner.persisted?
          end



          def find_proxy_target(ids = nil)
            ids = proxy_owner.send(metadata.foreign_key) if ids.nil?
            proxy_target_class.find(ids, :skip_expected_result_check => true)
          end

          def find_proxy_target_with_proc(options = {})
            [super].compact.flatten
          end

          def can_find_proxy_target?
            super || (proxy_owner.respond_to?(metadata.foreign_key) && proxy_owner.send(metadata.foreign_key).any?)
          end


          


          def add_foreign_key_in_proxy_owner(id)
            if update_foreign_key_fields_in_proxy_owner? && proxy_owner.respond_to?(metadata.foreign_key)
              proxy_owner.send(metadata.foreign_key) << id
              notify_of_change_in_proxy_owner_foreign_key
            end
          end

          def remove_foreign_key_in_proxy_owner(id)
            if proxy_owner.respond_to? metadata.foreign_key
              proxy_owner.send(metadata.foreign_key).delete(id)
              notify_of_change_in_proxy_owner_foreign_key
            end
          end

          def foreign_key_in_proxy_owner_exists?(id)
            proxy_owner.send(metadata.foreign_key).include? id
          end

          def notify_of_change_in_proxy_owner_foreign_key
            method = metadata.foreign_key+"_will_change!"
            proxy_owner.send(method) if proxy_owner.respond_to? method
          end
        end
      end
    end
  end
end
