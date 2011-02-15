module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesMany < Proxy

          def reset
            super
            @target = []
          end

          private


          def find_target
            target_class.find(owner.send(foreign_key))
          end

          def can_find_target?
            use_find_with? || owner.send(foreign_key).any? 
          end
        end
      end
    end
  end
end
