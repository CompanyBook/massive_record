module MassiveRecord

  class Connection
  
    attr_accessor :host, :port, :timeout
    
    def initialize(opts = {})
      @timeout = 4000
      @host    = opts[:host]
      @port    = opts[:port] || 9090
    end
        
    def transport
      @transport ||= Thrift::BufferedTransport.new(Thrift::Socket.new(@host, @port, @timeout))
    end
    
    def protocol
      Thrift::BinaryProtocol.new(transport)
    end
    
    def client
      @client ||= Apache::Hadoop::Hbase::Thrift::Hbase::Client.new(protocol)
    end
    
    def open
      transport.open()
    end
    
    def tables
      collection = TablesCollection.new
      collection.connection = self
      client.getTableNames().each{|table_name| collection.push(table_name)}
      collection
    end
    
    def load_table(table_name)
      MassiveRecord::Table.new(self, table_name)
    end
    
  end

end