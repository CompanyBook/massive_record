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
            records.flatten.each do |record|
              unless include? record
                raise_if_type_mismatch(record)
                proxy_target << record
                record.send(metadata.inverse_of).replace(proxy_owner, false)
              end
            end

            if proxy_owner.persisted?
              proxy_owner.save
            else
              proxy_target.sort_by! &:id
            end

            self
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
          # It filters away database_ids (keys in a column family)
          # which it does not recognize.
          #
          def proxy_targets_raw # :nodoc:
            Hash[proxy_owner.raw_data[metadata.store_in].collect do |database_id, value|
              begin
                base_class, id = Embedded.parse_database_id(database_id)
                [id, value] if base_class == proxy_target_class.base_class.to_s.underscore
              rescue InvalidEmbeddedDatabaseId
              end
            end.compact]
          end




          #
          # Hook which are called just before save.
          # It iterates over new or changed records, asking them to "save" themself.
          # This will result in created_at / updated_at and persistence state being set.
          # It will also build the proxy_targets_update_hash with these
          # changes, which will be used at the proxy owner's save for actually updating
          # these records.
          #
          def parent_will_be_saved! # :nodoc:
            proxy_targets_update_hash.clear

            MassiveRecord::ORM::Persistence::Operations.suppress do
              proxy_target.each do |record|
                if record.destroyed?
                  proxy_targets_update_hash[record.database_id] = nil
                elsif record.new_record? || record.changed?
                  record.save unless record.in_the_middle_of_saving?
                  proxy_targets_update_hash[record.database_id] = Base.coder.dump(record.attributes_db_raw_data_hash)
                end
              end

              to_be_destroyed.each do |record|
                targets_current_owner = record.send(metadata.inverse_of).proxy_target
                if targets_current_owner.nil? || targets_current_owner == proxy_owner
                  record.destroy
                  proxy_targets_update_hash[record.database_id] = nil
                end
              end
              to_be_destroyed.clear
            end
          end

          # Hook to call when save is done through parent
          def parent_has_been_saved!
            reload_raw_data
            proxy_targets_update_hash.clear
          end

          def proxy_targets_update_hash
            @proxy_targets_update_hash ||= {}
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
          rescue MassiveRecord::ORM::RecordNotFound
            # When we try to load raw data we might end up getting nil back, even though
            # a row exists with given id. The reason for this is that when only selecting
            # one column family (family for embedded records) and that family is empty for
            # a given row we'll end up getting nil back, resulting in a record not found error.
          end


          def find_one_embedded_record_from_raw_data(id)
            raw_data = proxy_targets_raw[id] || load_raw_data_for_id(id)
            instantiate_target_class(id, raw_data) if raw_data
          end

          def load_raw_data_for_id(id)
            database_id = Embedded.database_id(proxy_target_class, id)
            if cell = proxy_owner.class.table.get_cell(proxy_owner.id, metadata.store_in, database_id)
              RawData.new_with_data_from cell
            end
          end

          # FIXME Common to all proxies representing multiple values
          def find_proxy_target_with_proc(options = {}, &block)
            Array(super).compact
          end

          def delete_or_destroy(*records, method)
            records.flatten!
            self.proxy_target -= records
            to_be_destroyed.concat(records).uniq!
            proxy_owner.save if proxy_owner.persisted? && method == :destroy
            records
          end

          def can_find_proxy_target?
            true
          end


          def to_be_destroyed
            @to_be_destroyed ||= []
          end

          def instantiate_target_class(id, raw_data)
            proxy_target_class.send(:instantiate, *proxy_target_class.transpose_raw_data_to_record_attributes_and_raw_data(id, raw_data)).tap do |record|
              record.send(metadata.inverse_of).replace(proxy_owner, false)
            end
          end
        end
      end
    end
  end
end
