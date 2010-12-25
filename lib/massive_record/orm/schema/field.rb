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
          self.type = options[:type]
          self.default = options[:default]
        end

        def ==(other)
          other.instance_of?(self.class) && other.hash == hash
        end
        alias_method :eql?, :==

        def hash
          name.hash
        end

        private

        def name=(name)
          @name = name.to_s
        end
      end
    end
  end
end
