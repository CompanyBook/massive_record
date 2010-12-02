module MassiveRecord
  module ORM
    module AttributeMethods
      module Dirty
        extend ActiveSupport::Concern
        include ActiveModel::Dirty


        def save(*)
          if status = super
            changed_attributes.clear
          end
          status
        end

        def save!(*)
          super.tap do
            changed_attributes.clear
          end
        end

        def reload(*)
          super.tap do
            changed_attributes.clear
          end
        end


        def update(*)
          # TODO  If we can do partial updates against hbase
          #       then I think this is the place to put it.
          #       Or else, remove this method :-)
          super
        end


        def write_attribute(attr_name, value)
          attr_name = attr_name.to_s
          send("#{attr_name}_will_change!") unless read_attribute(attr_name) == value
          super
        end
      end
    end
  end
end
