module MassiveRecord
  module ORM
    module Relations
      class Proxy
        #
        # Proxy used to reference one other object in another table.
        #
        class ReferencesOne < Proxy

          def target=(target)
            owner.send(foreign_key_setter, target.id) if target && persisting_foreign_key?
            super(target)
          end


          private

          def find_target
            class_name.constantize.find(owner.send(foreign_key))
          end

          def can_find_target?
            use_find_with? || owner.send(foreign_key).present?
          end
        end
      end
    end
  end
end
