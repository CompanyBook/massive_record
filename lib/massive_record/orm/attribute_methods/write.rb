module MassiveRecord
  module ORM
    module AttributeMethods
      module Write
        extend ActiveSupport::Concern

        included do
          attribute_method_suffix "="
        end
        

        def write_attribute(attr_name, value)
          @attributes[attr_name] = value
        end

        private

        def attribute=(attr_name, value)
          write_attribute(attr_name, value)
        end
      end
    end
  end
end
