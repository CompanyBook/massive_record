module MassiveRecord
  module ORM
    module Schema
      class Field
        include ActiveModel::Validations

        TYPES_DEFAULTS_TO = {
          :string => '',
          :integer => 0,
          :float => 0.0,
          :boolean => false,
          :array => [],
          :hash => {},
          :date => lambda { Date.today },
          :time => lambda { Time.now }
        }.freeze

        TYPES = TYPES_DEFAULTS_TO.keys.freeze

        attr_writer :default
        attr_accessor :name, :column, :type, :fields, :coder, :allow_nil


        validates_presence_of :name
        validates_inclusion_of :type, :in => TYPES
        validate do
          errors.add(:fields, :blank) if fields.nil?
          errors.add(:name, :taken) if fields.try(:attribute_name_taken?, name)
        end

      
        #
        # Creates a new field based on arguments from DSL
        # args: name, type, options
        #
        def self.new_with_arguments_from_dsl(*args)
          field_options = args.extract_options!
          field_options[:name] = args[0]
          field_options[:type] ||= args[1]

          new(field_options)
        end



        def initialize(*args)
          options = args.extract_options!.to_options

          self.fields = options[:fields]
          self.name = options[:name]
          self.column = options[:column]
          self.type = options[:type] || :string
          self.default = options[:default]
          self.allow_nil = options.has_key?(:allow_nil) ? options[:allow_nil] : true

          self.coder = options[:coder] || Base.coder

          @@encoded_nil_value = coder.dump(nil)
          @@encoded_null_string = coder.dump("null")
        end


        def ==(other)
          other.instance_of?(self.class) && other.hash == hash
        end
        alias_method :eql?, :==

        def hash
          name.hash
        end

        def type=(type)
          @type = type.to_sym
        end


        def column
          @column || name
        end

        def default
          @default = TYPES_DEFAULTS_TO[type] if !allow_nil? && @default.nil?
          if @default.respond_to? :call
            @default.call
          else
            @default.duplicable? ? @default.dup : @default
          end
        end

        
        def unique_name
          raise "Can't generate a unique name as I don't have a column family!" if column_family.nil?
          [column_family.name, column].join(":")
        end

        def column_family
          fields.try :contained_in
        end

        def column=(column)
          column = column.to_s unless column.nil?
          @column = column
        end

        def allow_nil?
          !!allow_nil
        end



        def decode(value)
          value = value.force_encoding(Encoding::UTF_8) if utf_8_encoded? && !value.frozen? && value.respond_to?(:force_encoding) 

          return value if value.nil? || value_is_already_decoded?(value)
          
          value = case type
                  when :boolean
                    value.blank? || value == @@encoded_nil_value ? nil : !value.to_s.match(/^(true|1)$/i).nil?
                  when :date
                    value.blank? || value.to_s == "0" ? nil : (Date.parse(value) rescue nil)
                  when :time
                    value.blank? ? nil : (Time.parse(value) rescue nil)
                  when :string
                    if value.present?
                      value = value.to_s if value.is_a? Symbol
                      coder.load(value)
                    end
                  when :integer
                    if value =~ /\A\d*\Z/
                      coder.load(value) if value.present?
                    else
                      hex_string_to_integer(value)
                    end
                  when :float, :array, :hash
                    coder.load(value) if value.present?
                  else
                    raise "Unable to decode #{value}, class: #{value}"
                  end
          ensure
            unless loaded_value_is_of_valid_class?(value)
              raise SerializationTypeMismatch.new("Expected #{value} (class: #{value.class}) to be any of: #{classes.join(', ')}.")
            end
        end

        def encode(value)
          if value.nil? || should_not_be_encoded?
            value
          else
            value = value.try(:utc) if Base.time_zone_aware_attributes && field_affected_by_time_zone_awareness?
            coder.dump(value).to_s
          end
        end



        private

        def name=(name)
          @name = name.to_s
        end

        def classes
          classes = case type
                    when :boolean
                      [TrueClass, FalseClass]
                    when :integer
                      [Fixnum]
                    else
                      klass = type.to_s.classify
                      if ::Object.const_defined?(klass)
                        [klass.constantize]
                      end
                    end

          classes || []
        end

        def value_is_already_decoded?(value)
          if type == :string
            value.is_a?(String) && !(value == @@encoded_null_string || value == @@encoded_nil_value)
          elsif value.acts_like?(type)
            true
          else
            classes.include?(value.class)
          end
        end

        def loaded_value_is_of_valid_class?(value)
          value.nil? || value.is_a?(String) && value == @@encoded_nil_value || value_is_already_decoded?(value)
        end

        def field_affected_by_time_zone_awareness?
          type == :time
        end

        def hex_string_to_integer(string)
          Wrapper::Cell.hex_string_to_integer(string)
        end

        def utf_8_encoded?
          type != :integer
        end

        def should_not_be_encoded?
          [:string, :integer].include?(type)
        end
      end
    end
  end
end
