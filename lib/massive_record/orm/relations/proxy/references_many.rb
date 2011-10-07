module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesMany < ProxyCollection

          #
          # Raised when we are in a references many relationship where the
          # target's foreign keys are persisted in the owner and you try to
          # do a person.cars.all(:limit => 1, :offset => "something") and
          # some of these options are unsupported. The reason for these being
          # unsupported is that we have to implement offset and limitiation
          # in pure Ruby working on that car_ids array in the person. Its
          # nothing close to impossible; it just has not been done yet.
          #
          class UnsupportedFinderOption < MassiveRecordError
            OPTIONS = %w(limit offset starts_with)
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
          # Checks if record is included in collection
          #
          def include?(record_or_id)
            id = record_or_id.respond_to?(:id) ? record_or_id.id : record_or_id

            if loaded? || find_with_proc?
              !!find(id)
            else
              foreign_key_in_proxy_owner_exists? id
            end
          rescue RecordNotFound
            false
          end

          #
          # Returns the length of targes
          #
          def length
            if loaded?
              proxy_target.length
            elsif find_with_proc?
              load_proxy_target.length
            else
              foreign_keys_in_proxy_owner.length
            end
          end
          alias_method :count, :length
          alias_method :size, :length

          def any?
            if !loaded? && find_with_proc?
              !!first
            else
              !empty?
            end
          end
          alias_method :present?, :any?


          def find(id)
            if loaded? || proxy_owner.new_record?
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

          def all(options = {})
            options = MassiveRecord::Adapters::Thrift::Table.warn_and_change_deprecated_finder_options(options)

            load_proxy_target(options)
          end

          #
          # Find records in batches, yields batch into your block
          #
          # Options:
          #   <tt>:batch_size</tt>    The number of records you want per batch. Defaults to 1000
          #   <tt>:starts_with</tt>         The ids starts with this
          #
          def find_in_batches(options = {}, &block)
            options = MassiveRecord::Adapters::Thrift::Table.warn_and_change_deprecated_finder_options(options)

            options[:batch_size] ||= 1000

            if loaded?
              collection =  if options[:starts_with]
                              proxy_target.select { |r| r.id.starts_with? options[:starts_with] }
                            else
                              proxy_target
                            end
              collection.in_groups_of(options[:batch_size], false, &block)
            elsif find_with_proc?
              find_proxy_target_with_proc(options.merge(:finder_method => :find_in_batches), &block)
            else
              all_ids = proxy_owner.send(metadata.foreign_key)
              all_ids = all_ids.select { |id| id.starts_with? options[:starts_with] } if options[:starts_with]
              all_ids.in_groups_of(options[:batch_size]).each do |ids_in_batch|
                yield Array(find_proxy_target(:ids => ids_in_batch))
              end
            end
          end

          #
          # Fetches records in batches of 1000 (by default), iterates over each batch
          # and yields one and one record in to given block. See find_in_batches for
          # options.
          #
          def find_each(options = {})
            find_in_batches(options) do |batch|
              batch.each { |record| yield record }
            end
          end

          #
          # Returns a limited result set of target records.
          #
          # TODO  If we know all our foreign keys (basically we also know our length)
          #       we can then mark our self as loaded if limit is equal to or greater
          #       than foreign keys length.
          #
          def limit(limit)
            if loaded? || proxy_owner.new_record?
              proxy_target.slice(0, limit)
            elsif find_with_proc?
              find_proxy_target_with_proc(:limit => limit)
            else
              ids = proxy_owner.send(metadata.foreign_key).slice(0, limit)
              ids = ids.first if ids.length == 1
              Array(find_proxy_target(:ids => ids))
            end
          end


          def is_a?(klass)
            klass == Array
          end

          private


          def delete_or_destroy(*records, method)
            removed = []

            records.flatten.each do |record|
              if include? record
                removed << record
                remove_foreign_key_in_proxy_owner(record.id)
                proxy_target.delete(record)
                record.destroy if method.to_sym == :destroy
              end
            end

            proxy_owner.save if proxy_owner.persisted?
            removed
          end



          def find_proxy_target(options = {})
            ids = options.delete(:ids) || proxy_owner.send(metadata.foreign_key)
            unsupported_finder_options = UnsupportedFinderOption::OPTIONS & options.keys.collect(&:to_s)

            if unsupported_finder_options.any?
              raise UnsupportedFinderOption.new(
                <<-TXT
                  Sorry, option(s): #{unsupported_finder_options.join(', ')} are not supported when foreign
                  keys are persisted in proxy owner #{proxy_owner.class}
                TXT
              )
            end

            proxy_target_class.find(ids, :skip_expected_result_check => true)
          end

          def find_proxy_target_with_proc(options = {}, &block)
            Array(super).compact
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
            foreign_keys_in_proxy_owner.include? id
          end

          def foreign_keys_in_proxy_owner
            proxy_owner.send(metadata.foreign_key)
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
