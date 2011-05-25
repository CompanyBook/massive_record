module MassiveRecord
  module ORM
    module AttributeMethods

      #
      # Module for handling time zones
      #
      # Related attributes and configurations:
      #   Base.default_timezone                         
      #     is the zone persisted in the database
      #   Base.time_zone_aware_attributes
      #     is flag for disable / enable it altogether
      #   Base.skip_time_zone_conversion_for_attributes
      #     makes it possible to skip specific conversions on given attributes
      #
      #
      module TimeZoneConversion
        extend ActiveSupport::Concern

        included do
          # Determines whether to use Time.local (using :local) or Time.utc (using :utc)
          # when pulling dates and times from the database. This is set to :local by default.
          cattr_accessor :default_timezone, :instance_writer => false
          self.default_timezone = :local

          cattr_accessor :time_zone_aware_attributes, :instance_writer => false
          self.time_zone_aware_attributes = false

          class_attribute :skip_time_zone_conversion_for_attributes, :instance_writer => false
          self.skip_time_zone_conversion_for_attributes = []
        end



        module ClassMethods
          protected

          # Redefine reader method if we are to do time zone configuration on field
          def define_method_attribute(attr_name)
            if time_zone_conversion_on_field?(attributes_schema[attr_name])
              internal_read_method = "_#{attr_name}"

              if attr_name =~ ActiveModel::AttributeMethods::COMPILABLE_REGEXP
                generated_attribute_methods.module_eval <<-RUBY, __FILE__, __LINE__
                  def #{internal_read_method}
                    if time = decode_attribute('#{attr_name}', @attributes['#{attr_name}'])
                      time.in_time_zone
                    end
                  end

                  alias #{attr_name} #{internal_read_method}
                RUBY
              else
                generated_attribute_methods.send(:define_method, internal_read_method) do
                  if time = decode_attribute(attr_name, @attributes[attr_name])
                    time.in_time_zone
                  end
                end
              end
            else
              super
            end
          end

          # Redefine writer method if we are to do time zone configuration on field
          def define_method_attribute=(attr_name)
            # Nothing special goes on here, at the moment
            super
          end


          private

          def time_zone_conversion_on_field?(field)
            field && time_zone_aware_attributes && !skip_time_zone_conversion_for_attributes.include?(field.name) && field.type == :time
          end
        end
      end
    end
  end
end
