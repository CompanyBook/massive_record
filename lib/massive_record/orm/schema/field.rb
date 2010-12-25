module MassiveRecord
  module ORM
    module Schema
      class Field
        include ActiveModel::Validations

        attr_accessor :name, :column_family, :column, :type, :default, :fields


        validates_presence_of :name
        validate do
          errors.add(:fields, :blank) if fields.nil?
          errors.add(:name, :taken) if fields.try(:attribute_name_taken?, name)
        end


        def initialize(*args)
          options = args.extract_options!.to_options

          self.fields = options[:fields]
          self.name = options[:name]
          self.column = options[:column]
          self.column_family = options[:column_family]
          self.type = options[:type] || :string
          self.default = options[:default]
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

        def decode(value)
          return nil if value.nil?

          if type == :boolean
            return value if value === TrueClass || value === FalseClass
          else
            return value if value.class == type.to_s.classify.constantize
          end
          
          case type
          when :string
            value
          when :boolean
            value.to_s.empty? ? nil : !value.to_s.match(/^(true|1)$/i).nil?
          when :integer
            value.to_s.empty? ? nil : value.to_i
          when :date
            value.empty? ? nil : Date.parse(value)
          when :time
            value.empty? ? nil : Time.parse(value)
          when :array
            value
          when :hash
            value
          else
            value
          end
        end



        private

        def name=(name)
          @name = name.to_s
        end
      end
    end
  end
end
