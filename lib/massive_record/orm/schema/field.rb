module MassiveRecord
  module ORM
    module Schema
      class Field
        attr_accessor :name, :column_family, :column, :type, :default

        def initialize(*args)
          options = args.extract_options!.to_options

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
