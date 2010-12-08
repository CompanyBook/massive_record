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
        @attributes ||= {}
      end

      def attributes=(new_attributes)
        return unless new_attributes.is_a?(Hash)
        attributes = new_attributes.stringify_keys

        # TODO  We might want to sanitize attributes against field definition.
        #       The insurances of that the id exists like I'm doing here might
        #       (should? :-)) be handled another way too. I'm doing this for now
        #       just to make sure that define_attribute_methods actually defines
        #       read/write method for it.
        @attributes = {'id' => nil}.merge(attributes)
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
