module MassiveRecord
  module ORM
    module Relations
      class Proxy
        #
        # Proxy used to reference one other object in another table.
        #
        class ReferencesOne < Proxy

          def target=(target)
            set_foreign_key_in_proxy_owner(target.id) if target
            super(target)
          end

          def replace(target)
            super
            set_foreign_key_in_proxy_owner(nil) if target.nil?
          end


          private

          def find_target
            target_class.find(proxy_owner.send(foreign_key))
          end

          def can_find_target?
            super || proxy_owner.send(foreign_key).present?
          end

          def set_foreign_key_in_proxy_owner(id)
            proxy_owner.send(foreign_key_setter, id) if proxy_owner.respond_to?(foreign_key_setter)
          end
        end
      end
    end
  end
end
