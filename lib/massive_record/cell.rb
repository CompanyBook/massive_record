module MassiveRecord
  
  class Cell
    
    attr_accessor :value, :created_at
    
    def initialize(opts = {})
      @value = opts[:value]
      @created_at = opts[:created_at]
    end
     
  end
  
end