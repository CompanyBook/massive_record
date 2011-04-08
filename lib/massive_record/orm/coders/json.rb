require 'active_support/json'

module MassiveRecord
  module ORM
    module Coders
      class JSON
        def dump(object)
          ActiveSupport::JSON.encode(object)
        end

        def load(json)
          ActiveSupport::JSON.decode(json)
        end
      end
    end
  end
end
