module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesMany < Proxy

          def reset
            super
            @target = []
          end


          #
          # Adding record(s) to the collection.
          #
          def <<(*records)
            records.flatten.each do |record|
              unless include? record
                raise_if_type_mismatch(record)
                add_foreign_key_in_owner(record.id)
                target << record
              end
            end

            self
          end
          alias_method :push, :<<
          alias_method :concat, :<<
          #
          # Checks if record is included in collection
          #
          # TODO  This needs a bit of work, depending on if proxy's target
          #       has been loaded or not. For now, we are just checking
          #       what we currently have in @target
          #
          def include?(record)
            target.include? record
          end
          private


          def find_target
            target_class.find(owner.send(foreign_key))
          end

          def find_target_with_proc
            [super].flatten
          end

          def can_find_target?
            super || owner.send(foreign_key).any? 
          end


          def add_foreign_key_in_owner(id)
            will_change_notification_method = foreign_key+"_will_change!"

            if owner.respond_to? foreign_key_setter
              owner.send(foreign_key) << id
              owner.send(will_change_notification_method) if owner.respond_to? will_change_notification_method
            end
          end
        end
      end
    end
  end
end
