unless ActiveModel::AttributeMethods.const_defined? 'COMPILABLE_REGEXP'
  ActiveModel::AttributeMethods::COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?=]?\Z/
end

module MassiveRecord
  module ORM
    module AttributeMethods
      extend ActiveSupport::Concern
      include ActiveModel::AttributeMethods      
      include ActiveModel::MassAssignmentSecurity

      module ClassMethods
        def define_attribute_methods
          super(known_attribute_names)
          @attribute_methods_generated = true
        end

        def attribute_methods_generated?
          @attribute_methods_generated ||= false
        end

        def undefine_attribute_methods(*args)
          super
          @attribute_methods_generated = false
        end

        def attributes_protected_by_default
          ['id', inheritance_attribute]
        end
      end


      def attributes
        Hash[@attributes.collect { |attr_name, raw_value| [attr_name, read_attribute(attr_name)] }]
      end
      
      def attributes=(new_attributes)
        return unless new_attributes.is_a?(Hash)

        sanitize_for_mass_assignment(new_attributes).each do |attr, value|
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


      protected

      def attribute_method?(attr_name)
        attr_name == 'id' || (defined?(@attributes) && @attributes.include?(attr_name))
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
