module MassiveRecord
  module ORM
    module Relations
      module Interface
        extend ActiveSupport::Concern

        included do
          class_attribute :relations, :instance_writer => false
          self.relations = Set.new
        end


        module ClassMethods
          def references_one(name, *args)

          end
        end
      end
    end
  end
end
