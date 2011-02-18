module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesOnePolymorphic < Proxy
          def target=(target)
            set_foreign_key_and_type_in_owner(target.id, target.class.to_s.underscore) if target
            super(target)
          end

          def target_class
            owner.send(polymorphic_type_column).classify.constantize
          end

          def replace(target)
            super
            set_foreign_key_and_type_in_owner(nil, nil) if target.nil?
          end


          private

          def find_target
            target_class.find(owner.send(foreign_key))
          end

          def can_find_target?
            super || (owner.send(foreign_key).present? && owner.send(polymorphic_type_column).present?)
          end

          def set_foreign_key_and_type_in_owner(id, type)
            owner.send(foreign_key_setter, id) if owner.respond_to?(foreign_key_setter)
            owner.send(polymorphic_type_column_setter, type) if owner.respond_to?(polymorphic_type_column_setter)
          end



          private

          def raise_if_type_mismatch(record)
            # By nature this can't be checked, as it should acept all types.
          end
        end
      end
    end
  end
end
