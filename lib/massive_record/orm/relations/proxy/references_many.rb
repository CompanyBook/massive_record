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

          def find_target_with_proc
            [super].flatten
          end

          def can_find_target?
            super || owner.send(foreign_key).any? 
          end
        end
      end
    end
  end
end
