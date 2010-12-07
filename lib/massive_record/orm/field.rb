module MassiveRecord
  module ORM
    class Field
      attr_accessor :column_family, :column, :type, :default
      
      def initialize(*args)
        @column = args[0]
        @type = [Symbol, String].include?(args[1].class) ? args[1].to_sym : :string
        opts = args[1].is_a?(Hash) ? args[1] : args[2] || {}
        @default = opts[:default]        
      end
      
      def name
        "#{column_family}:#{column}"
      end
    end
  end
end
