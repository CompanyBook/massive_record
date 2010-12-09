module MassiveRecord
  module ORM
    module AttributeMethods
      module Schema
        
        extend ActiveSupport::Concern
        
        included do
          class_attribute :attributes_schema, :instance_writer => false
          self.attributes_schema = {}
        end
                
        def default_attributes_from_schema
          h = {}
          attributes_schema.each{|k, v| h[v.name] = v.default}
          h
        end      
        
      end
    end
  end
end
