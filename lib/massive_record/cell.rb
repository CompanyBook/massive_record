require 'json'

module MassiveRecord
  
  class Cell
    
    attr_writer :value
    attr_accessor :created_at
    
    def initialize(opts = {})
      @value = opts[:value]
      @created_at = opts[:created_at]
    end
    
    def value
      @value.is_a?(String) ? @value.to_s.force_encoding(Encoding::UTF_8) : @value
    end
    
    def deserialize_value
      @value.is_a?(String) ? Marshal.load(@value) : @value
    end
    
    def self.serialize_value(v)
      v.is_a?(String) ? v : Marshal.dump(v)
    end
    
    def serialize_value(v)
      @value = self.class.serialize_value(v)
    end
    
    def serialized_value
      self.class.serialize_value(@value)
    end
    
  end
  
end