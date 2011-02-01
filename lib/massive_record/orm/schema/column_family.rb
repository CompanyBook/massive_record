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

          if options.has_key? :autoload
            # TODO remove this for next version
            ActiveSupport::Deprecation.warn("autoload is deprecated as an intitializer option. Please use autoload_fields instead!")
            options[:autoload_fields] = options.delete :autoload
          end

          self.name = options[:name]
          self.column_families = options[:column_families]
          self.autoload_fields = options[:autoload_fields]
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



        def autoload_fields?
          @autoload_fields == true
        end

        def autoload?
          # TODO remove this method for next version
          ActiveSupport::Deprecation.warn("ColumnFamily#autoload? is deprecated. Please use autoload_fields? instead")
          autoload_fields?
        end


        private
        
        def name=(name)
          @name = name.to_s
        end
        



        # Internal DSL method
        def field(*args)
          self << Field.new_with_arguments_from_dsl(*args)
        end

        # Internal DSL method
        def timestamps
          field :created_at, :time
        end

        # Internal DSL method
        def autoload_fields
          @autoload_fields = true
        end

        def autoload
          # TODO remove this method for next version
          ActiveSupport::Deprecation.warn("ColumnFamily#autoload DSL call is deprecated. Please use autoload_fields instead")
          autoload
        end
      end
    end
  end
end
