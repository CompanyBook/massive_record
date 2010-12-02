module MassiveRecord
  module ORM
    module AttributeMethods
      extend ActiveSupport::Concern
      include ActiveModel::AttributeMethods      

      module ClassMethods
        # TODO  Remove the attributes-argument and read it from the
        #       fields definition of the class instead (You'll have to
        #       update two calls to it as well made in method_missing / respond_to?)
        def define_attribute_methods(attr_names)
          super(attr_names)
        end
      end


      def attributes
        @attributes
      end

      def attributes=(attr)
        @attributes = attr.stringify_keys!
      end

      
      def method_missing(method, *args, &block)
        unless self.class.attribute_methods_generated?
          self.class.define_attribute_methods(attributes.keys)
          send(method, *args, &block)
        else
          super
        end
      end

      def respond_to?(*args)
        self.class.define_attribute_methods(attributes.keys) unless self.class.attribute_methods_generated?
        super
      end
    end
  end
end
