module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesOnePolymorphic < Proxy





          private

          def raise_if_type_mismatch(record)
            # By nature this can't be checked, as it should acept all types.
          end
        end
      end
    end
  end
end
