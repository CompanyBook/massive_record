module MassiveRecord
  module ORM
    module AttributeMethods
      extend ActiveSupport::Concern
      include ActiveModel::AttributeMethods      

      module ClassMethods
        def define_attribute_methods
          super(known_attribute_names)
        end
      end


      def attributes
        Hash[@attributes.collect { |attr_name, raw_value| [attr_name, read_attribute(attr_name)] }]
      end
      
      def attributes=(new_attributes)
        return unless new_attributes.is_a?(Hash)

        new_attributes.each do |attr, value|
          writer_method = "#{attr}="
          if respond_to? writer_method
            send(writer_method, value)
          else
            raise UnknownAttributeError.new("Unkown attribute: #{attr}")
          end
        end
      end

      
      def method_missing(method, *args, &block)
        unless self.class.attribute_methods_generated?
          self.class.define_attribute_methods
          send(method, *args, &block)
        else
          super
        end
      end

      def respond_to?(*args)
        self.class.define_attribute_methods unless self.class.attribute_methods_generated?
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

      def fill_attributes_with_default_values_where_nil_is_not_allowed
        attributes_schema.reject { |attr_name, field| field.allow_nil? || self[attr_name].present? }.each do |attr_name, field|
          self[attr_name] = field.default
        end
      end
    end
  end
end
