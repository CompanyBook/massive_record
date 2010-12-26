module MassiveRecord
  module ORM
    module Schema
      module ColumnInterface
        extend ActiveSupport::Concern

        included do

        end

        module ClassMethods
          def default_attributes_from_schema
            Hash.new
          end
        end
      end
    end
  end
end
