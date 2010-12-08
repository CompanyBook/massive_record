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

        new_attributes.each do |attr, value|
          # TODO check if we respond to it, raise error if we don't
          send("#{attr}=", value)
        end
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

      private

      def attributes_raw=(new_attributes)
        return unless new_attributes.is_a?(Hash)
        attributes = new_attributes.stringify_keys
        @attributes = {'id' => nil}.merge(attributes)
      end

      def attributes_from_field_definition
        attributes = {'id' => nil}
        attributes.merge! default_attributes_from_schema if respond_to? :default_attributes_from_schema
        attributes
      end
    end
  end
end
