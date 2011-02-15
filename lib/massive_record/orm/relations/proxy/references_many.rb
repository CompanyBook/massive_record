module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesMany < Proxy


          private


          def find_target
            
          end

          def can_find_target?
          end
          
          def raise_if_type_mismatch(record)
            # ..might be removed. Right now defined just to not raise anything.
          end
        end
      end
    end
  end
end
