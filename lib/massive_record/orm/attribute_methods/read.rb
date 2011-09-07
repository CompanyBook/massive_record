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
            internal_read_method = "_#{attr_name}"

            if attr_name =~ ActiveModel::AttributeMethods::COMPILABLE_REGEXP
              generated_attribute_methods.module_eval <<-RUBY, __FILE__, __LINE__
                def #{internal_read_method}
                  decode_attribute('#{attr_name}', @attributes['#{attr_name}'])
                end

                alias #{attr_name} #{internal_read_method}
              RUBY
            else
              generated_attribute_methods.send(:define_method, internal_read_method) do
                decode_attribute(attr_name, @attributes[attr_name])
              end
              alias_method "#{attr_name}", "#{internal_read_method}"
            end
          end
        end


        def read_attribute(attr_name)
          attr_name = attr_name.to_s
          internal_read_method = "_#{attr_name}"

          if respond_to? internal_read_method
            send(internal_read_method)
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
