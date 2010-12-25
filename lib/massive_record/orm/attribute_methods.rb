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
      
      # TODO : Need to be removed after the id attribute is moved out of the attributes hash
      def attributes_without_id
        a = attributes.dup
        a.delete("id")
        a
      end

      def attributes=(new_attributes)
        return unless new_attributes.is_a?(Hash)

        new_attributes.each do |attr, value|
          writer_method = "#{attr}="
          if respond_to? writer_method
            send(writer_method, value)
          else
            raise UnkownAttributeError.new("Unkown attribute: #{attr}")
          end
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
        attributes.merge! self.class.default_attributes_from_schema if self.class.respond_to? :default_attributes_from_schema
        attributes
      end
    end
  end
end
