module MassiveRecord
  module ORM
    module Coders
      class YAML
        def dump(object)
          ::YAML.dump(object)
        end

        def load(yaml)
          ::YAML.load(yaml)
        end
      end
    end
  end
end
