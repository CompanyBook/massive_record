module MassiveRecord
  module ORM
    module AttributeMethods
      module CastNumbersOnWrite
        extend ActiveSupport::Concern

        def write_attribute(attr_name, value)
          if value.present?
            if field = attributes_schema[attr_name]
              case field.type
              when :integer
                value = value.to_i
              when :float
                value = value.to_f
              end
            end
          end

          super
        end
      end
    end
  end
end
