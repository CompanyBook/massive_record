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
      
      def decode(value)
        return nil if value.nil?
        
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
      
    end
  end
end
