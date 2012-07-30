require 'active_support/json'

module MassiveRecord
  module ORM
    module Coders
      class JSON
        def dump(object)
          ActiveSupport::JSON.encode(object)
        end

        def load(json)
          # valid JSON begins with a { or [
          return ActiveSupport::JSON.decode(json) if json.starts_with?('{', '[')
          
          # null should be converted to nil
          return nil if json == 'null'
          
          # wrap it in quotes if its not a number and not already quoted
          begin
            Float(json)
          rescue
            json = "\"#{json}\"" if (json !~ /^'.*'$/ && json !~ /^".*"$/)
          end
          
          # coerce into an array then get the first element
          ActiveSupport::JSON.decode("[#{json}]").first
        end
      end
    end
  end
end
