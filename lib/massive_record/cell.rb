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
      @value.is_a?(String) ? self.class.convert_string(@value) : @value
    end
    
    def self.convert_string(str)
      str.to_s.force_encoding(Encoding::UTF_8)
    end
    
    def self.convert_hash(hash)
      hash.inject({}) do |h,(k,v)|
        if v.is_a?(String)
          h[k] = convert_string(v)
        elsif v.is_a?(Hash)
          h[k] = convert_hash(v)
        elsif v.is_a?(Array)
          h[k] = convert_array(v)
        end
        h
      end      
    end
    
    def self.convert_array(ar)
      ar.collect do |k|
        if k.is_a?(String)
          convert_string(k)
        elsif k.is_a?(Hash)
          convert_hash(k)
        elsif k.is_a?(Array)
          convert_array(k)
        end
      end
    end
    
    def deserialize_value
      @value.is_a?(String) ? JSON.parse(@value) : @value
    end
    
    def self.serialize_value(v)
      if v.is_a?(String)
        v
      elsif v.is_a?(Hash)
        v.to_json
      elsif v.is_a?(Array)
        v.to_json
      end
    end
    
    def serialize_value(v)
      @value = self.class.serialize_value(v)
    end
    
    def serialized_value
      self.class.serialize_value(@value)
    end
    
  end
  
end