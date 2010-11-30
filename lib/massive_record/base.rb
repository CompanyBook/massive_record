module MassiveRecord
    
  class Base
    
    def self.config
      config = YAML.load_file(Rails.root.join('config', 'hbase.yml'))[Rails.env]
      { :host => config['host'], :port => config['port'] }        
    end

    def self.connection
      conn = Connection.new(config)
      conn.open
      conn
    end
    
    def self.table
      # TODO
    end
    
    def self.column
      # TODO
    end
  
  end  

end