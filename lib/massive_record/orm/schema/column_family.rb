module MassiveRecord
  module ORM
    module Schema
      class ColumnFamily
        include ActiveModel::Validations

        attr_accessor :column_families, :autoload_fields
        attr_reader :name, :fields


        validates_presence_of :name
        validate do
          errors.add(:column_families, :blank) if column_families.nil?
          errors.add(:base, :invalid_fields) unless fields.all? { |field| field.valid? }
        end


        delegate :add, :add?, :<<, :to_hash, :attribute_names, :field_by_name, :to => :fields


        def initialize(*args)
          options = args.extract_options!
          options.symbolize_keys!

          @fields = Fields.new
          @fields.contained_in = self

          self.name = options[:name]
          self.column_families = options[:column_families]
          self.autoload_fields = options[:autoload_fields] || options[:autoload] # FIXME deprecated
        end

        def ==(other)
          other.instance_of?(self.class) && other.hash == hash
        end
        alias_method :eql?, :==

        def hash
          name.hash
        end

        def contained_in=(column_families)
          self.column_families = column_families
        end

        def contained_in
          column_families
        end

        def attribute_name_taken?(name, check_only_self = false)
          name = name.to_s
          check_only_self || contained_in.nil? ? fields.attribute_name_taken?(name, true) : contained_in.attribute_name_taken?(name)
        end


        #
        # Extracts the fields belonging to this column family.
        # column_names should be an array with full column names like
        # [info:name, info:phone, misc:other].
        #
        def populate_fields_from_column_names(column_names)
          column_names.each do |column_family_and_column_name|
            family_name, column_name = column_family_and_column_name.split(":")
            self.add? Field.new(:name => column_name) if family_name == name
          end
        end

        def autoload_fields?
          @autoload_fields == true
        end
        alias_method :autoload?, :autoload_fields? # FIXME deprecated


        private
        
        def name=(name)
          @name = name.to_s
        end
        



        # Internal DSL method
        def field(*args)
          options = args.extract_options!
          options[:name] = args[0]
          options[:type] = args[1]
          self << Field.new(options)
        end


        # Internal DSL method
        def autoload_fields
          @autoload_fields = true
        end
        alias_method :autoload, :autoload_fields # FIXME deprecated
      end
    end
  end
end
