module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class EmbeddedIn < Proxy
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

