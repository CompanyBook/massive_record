module MassiveRecord
  module ORM
    module AttributeMethods
      module Read
        extend ActiveSupport::Concern

        included do
          attribute_method_suffix ""
        end
        
        def read_attribute(attr_name)
          attr_name = attr_name.to_s
          decode_attribute(attr_name, @attributes[attr_name])
        end

        private

        def attribute(attr_name)
          read_attribute(attr_name)
        end

        def decode_attribute(attr_name, value)
          attributes_schema[attr_name].nil? ? value : attributes_schema[attr_name].decode(value)
        end
      end
    end
  end
end
