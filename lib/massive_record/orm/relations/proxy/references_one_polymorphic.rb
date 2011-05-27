module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class ReferencesOnePolymorphic < Proxy
          def proxy_target=(proxy_target)
            set_foreign_key_and_type_in_proxy_owner(proxy_target.id, proxy_target.class.to_s) if proxy_target
            super(proxy_target)
          end

          def proxy_target_class
            proxy_owner.send(metadata.polymorphic_type_column).classify.constantize
          end

          def replace(proxy_target)
            super
            set_foreign_key_and_type_in_proxy_owner(nil, nil) if proxy_target.nil?
          end


          private

          def find_proxy_target
            proxy_target_class.find(proxy_owner.send(metadata.foreign_key))
          end

          def can_find_proxy_target?
            super || (proxy_owner.send(metadata.foreign_key).present? && proxy_owner.send(metadata.polymorphic_type_column).present?)
          end

          def set_foreign_key_and_type_in_proxy_owner(id, type)
            if update_foreign_key_fields_in_proxy_owner?
              proxy_owner.send(metadata.foreign_key_setter, id) if proxy_owner.respond_to?(metadata.foreign_key_setter)
              proxy_owner.send(metadata.polymorphic_type_column_setter, type) if proxy_owner.respond_to?(metadata.polymorphic_type_column_setter)
            end
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
