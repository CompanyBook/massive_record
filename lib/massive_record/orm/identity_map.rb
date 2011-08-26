module MassiveRecord
  module ORM
    class IdentityMap
      class << self
        def enabled=(boolean)
          Thread.current[:identity_map_enabled] = !!boolean
        end

        def enabled
          Thread.current[:identity_map_enabled]
        end
        alias enabled? enabled
      end
    end
  end
end
