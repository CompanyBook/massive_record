module MassiveRecord
  module ORM
    module AttributeMethods
      module Write
        extend ActiveSupport::Concern

        included do
          attribute_method_suffix "="
        end
        

        module ClassMethods
          protected

          def define_method_attribute=(attr_name)
            if attr_name =~ ActiveModel::AttributeMethods::COMPILABLE_REGEXP
              generated_attribute_methods.module_eval <<-RUBY, __FILE__, __LINE__
                def #{attr_name}=(value)
                  write_attribute('#{attr_name}', value)
                end
              RUBY
            else
              generated_attribute_methods.send(:define_method, "#{attr_name}=") do |value|
                write_attribute(attr_name, value)
              end
            end
          end
        end

        def write_attribute(attr_name, value)
          @attributes[attr_name.to_s] = value
        end

        private

        def attribute=(attr_name, value)
          write_attribute(attr_name, value)
        end
      end
    end
  end
end
