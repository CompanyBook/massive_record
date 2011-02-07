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
          attributes_schema[attr_name].nil? ? @attributes[attr_name] : attributes_schema[attr_name].decode(@attributes[attr_name])
        end

        private

        def attribute(attr_name)
          read_attribute(attr_name)
        end
      end
    end
  end
end
