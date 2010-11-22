require 'json'

module MassiveRecord
  
  class Cell
    
    attr_accessor :value, :created_at
    
    def initialize(opts = {})
      @value = opts[:value]
      @created_at = opts[:created_at]
    end
    
    def deserialize_value
      @value.is_a?(String) ? JSON.parse(@value) : @value
    end
    
    def self.serialize_value(v)
      if v.is_a?(String)
        v
      elsif v.is_a?(Hash) || v.is_a?(Array)
        v.to_json
      end
    end
    
    def serialize_value(v)
      @value = self.class.serialize_value(v)
    end
    
  end
  
end