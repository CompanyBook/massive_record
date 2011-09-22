module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class EmbeddedInPolymorphic < EmbeddedIn
          private

          # Skip check on polymorphic relation
          def raise_if_type_mismatch(record)
          end
        end
      end
    end
  end
end
