module MassiveRecord
  
  class Column
    
    attr_accessor :name, :cells
    
    def initialize(opts = {})
      @name = opts[:name]
      @cells = opts[:cells] || []
    end
     
  end
  
end