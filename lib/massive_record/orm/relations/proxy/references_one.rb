module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesOne < Proxy




          private

          def find_target
            class_name.constantize.find(owner.send(foreign_key))
          end
        end
      end
    end
  end
end
