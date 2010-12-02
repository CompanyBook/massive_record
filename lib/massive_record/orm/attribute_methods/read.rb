module MassiveRecord
  module ORM
    module AttributeMethods
      module Read
        extend ActiveSupport::Concern

        included do
          attribute_method_suffix ""
        end
        

        def read_attribute(attr_name)
          @attributes[attr_name.to_s]
        end

        private

        def attribute(attr_name)
          read_attribute(attr_name)
        end
      end
    end
  end
end
