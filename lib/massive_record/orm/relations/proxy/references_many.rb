module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesMany < Proxy

          #
          # Loading targets will merge it with records found currently in proxy,
          # to make sure we don't remove any pushed targets only cause we load the
          # targets.
          #
          def load_target
            target_before_load = target
            target_after_load = super

            self.target = (target_before_load + target_after_load).uniq
          end

          def reset
            super
            @target = []
          end

          def replace(*records)
            records.flatten!

            if records.length == 1 and records.first.nil?
              reset
            else
              self.target = records.flatten
            end
          end


          #
          # Adding record(s) to the collection.
          #
          def <<(*records)
            save_records = owner.persisted?

            if records.flatten.all? &:valid?
              records.flatten.each do |record|
                unless include? record
                  raise_if_type_mismatch(record)
                  add_foreign_key_in_owner(record.id)
                  target << record
                  record.save if save_records
                end
              end

              owner.save if save_records

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
          # Destroy record(s) from the collection
          # Each record will be asked to delete itself as well
          #
          def delete(*records)
            delete_or_destroy *records, :delete
          end

          #
          # 
          #
          def destroy_all
            destroy(load_target)
            reset
            loaded!
          end

          #
          # Checks if record is included in collection
          #
          # TODO  This needs a bit of work, depending on if proxy's target
          #       has been loaded or not. For now, we are just checking
          #       what we currently have in @target
          #
          def include?(record)
            load_target.include? record
          end

          def length
            load_target.length
          end

          def empty?
            length == 0
          end



          private


          def delete_or_destroy(*records, method)
            records.flatten.each do |record|
              if include? record
                remove_foreign_key_in_owner(record.id)
                target.delete(record)
                record.send(method)
              end
            end

            owner.save if owner.persisted?
          end



          def find_target
            target_class.find(owner.send(foreign_key), :skip_expected_result_check => true)
          end

          def find_target_with_proc
            [super].compact.flatten
          end

          def can_find_target?
            super || (owner.respond_to?(foreign_key) && owner.send(foreign_key).any?)
          end


          


          def add_foreign_key_in_owner(id)
            if owner.respond_to? foreign_key
              owner.send(foreign_key) << id
              notify_of_change_in_owner_foreign_key
            end
          end

          def remove_foreign_key_in_owner(id)
            if owner.respond_to? foreign_key
              owner.send(foreign_key).delete(id)
              notify_of_change_in_owner_foreign_key
            end
          end

          def notify_of_change_in_owner_foreign_key
            method = foreign_key+"_will_change!"
            owner.send(method) if owner.respond_to? method
          end
        end
      end
    end
  end
end
