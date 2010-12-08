module MassiveRecord
  module ORM
    class Field
      attr_accessor :name, :column_family, :column, :type, :default
      
      def initialize(*args)
        @name = args[0]
        @type = [Symbol, String].include?(args[1].class) ? args[1].to_sym : :string
        opts = args[1].is_a?(Hash) ? args[1] : args[2] || {}
        @default = opts[:default] 
        @column = opts[:column] || @name       
      end
      
      def unique_name
        "#{column_family}:#{column}"
      end
    end
  end
end
