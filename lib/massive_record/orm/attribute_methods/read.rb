module MassiveRecord
  module ORM
    module AttributeMethods
      module Read
        extend ActiveSupport::Concern

        included do
          attribute_method_suffix ""
        end
        

        module ClassMethods
          protected

          def define_method_attribute(attr_name)
            if attr_name =~ ActiveModel::AttributeMethods::COMPILABLE_REGEXP
              generated_attribute_methods.module_eval <<-RUBY, __FILE__, __LINE__
                def #{attr_name}
                  decode_attribute('#{attr_name}', @attributes['#{attr_name}'])
                end
              RUBY
            else
              generated_attribute_methods.send(:define_method, attr_name) do
                decode_attribute(attr_name, @attributes[attr_name])
              end
            end
          end
        end


        def read_attribute(attr_name)
          attr_name = attr_name.to_s

          if respond_to? attr_name
            send(attr_name) if attributes_schema.has_key? attr_name
          else
            decode_attribute(attr_name, @attributes[attr_name])
          end
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
