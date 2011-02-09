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
            metadata = Metadata.new(name, *args)
            self.relations << metadata
            create_references_one_accessors_for(metadata)
          end

          private


          def create_references_one_accessors_for(metadata)
            proxy = Proxy.new()
            
            redefine_method(metadata.name) do
              
            end

            redefine_method(metadata.name+'=') do |record|
              
            end

            if metadata.persisting_foreign_key?
              redefine_method(metadata.foreign_key) do

              end

              redefine_method(metadata.foreign_key+'=') do |id|

              end
            end
          end
        end
      end
    end
  end
end
