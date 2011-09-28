module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class EmbeddedIn < Proxy

          def replace(proxy_target, update_inverse_relation = true)
            proxy_target_was = self.proxy_target

            super(proxy_target).tap do |proxy_target_is|
              if update_inverse_relation
                if proxy_target_is.present?
                  if proxy_target_was.nil?
                    proxy_target_is.send(metadata.inverse_of).push proxy_owner
                  elsif proxy_target_was != proxy_target_is
                    proxy_target_was.send(metadata.inverse_of).delete(proxy_owner)
                    proxy_target_was.save if proxy_target_was.persisted?
                    proxy_target_is.send(metadata.inverse_of).push proxy_owner
                  end
                end
              end
            end
          end

          def reset(force = false)
            # Does nothing.. if we are resetting this inside of an embedded setting
            # we will lose the knowledge about parent.
            super if force
          end


          private


          # We can never load proxy target,
          # it will always be set for us, as we live
          # inside of our own target
          def can_find_proxy_target?
            false
          end
        end
      end
    end
  end
end
