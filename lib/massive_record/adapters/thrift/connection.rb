require 'active_support/notifications'

module MassiveRecord
  module Adapters
    module Thrift
      class Connection
  
        attr_accessor :host, :hosts, :port, :timeout, :current_host
    
        def initialize(opts = {})
          @timeout      = opts[:timeout] || 4
          @host         = opts[:host]
          @hosts        = opts[:hosts]
          @port         = opts[:port] || 9090
          @reconnect    = opts[:reconnect].nil? ? true : opts[:reconnect]

          @instrumenter = ActiveSupport::Notifications.instrumenter
        end
      
        def transport
          @transport ||= ::Thrift::BufferedTransport.new(::Thrift::Socket.new(current_host, port, timeout))
        end
      
        def open(options = {})
          populateCurrentHost

          options = options.merge({
            :adapter => 'Thrift',
            :host => current_host,
            :port => port
          })

          @instrumenter.instrument "adapter_connecting.massive_record", options do
            protocol = ::Thrift::BinaryProtocol.new(transport)
            @client = Apache::Hadoop::Hbase::Thrift::Hbase::Client.new(protocol)

            begin
              transport.open()
              true
            rescue
              raise MassiveRecord::Wrapper::Errors::ConnectionException.new, "Unable to connect to HBase on #{current_host}, port #{port}"
            end
          end
        end
      
        def close
          @transport.nil? || @transport.close.nil?
        rescue IOError
          true          
        end
          
        def client
          @client
        end
      
        def open?
          @transport.try("open?")
        end
      
        def tables
          collection = MassiveRecord::Wrapper::TablesCollection.new
          collection.connection = self
          (getTableNames() || {}).each{|table_name| collection.push(table_name)}
          collection
        rescue => e
          if @reconnect && reconnect?(e)
            reconnect!(e)
            tables if client    
          else
            raise e
          end
        end
    
        def load_table(table_name)
          MassiveRecord::Wrapper::Table.new(self, table_name)
        end
    
        # Wrapp HBase API to be able to catch errors and try reconnect
        def method_missing(method, *args)
          open if not client
          client.send(method, *args) if client
        rescue => e
          if @reconnect && reconnect?(e)
            reconnect!(e)
            send(method, *args) if client    
          else
            raise e
          end
        end

        private

        # Unstable or closed connection:
        # IOError: unable to perform a read or write
        # TransportException: some packets where lost
        # ApplicationException: issue to get data
        def reconnect?(e)
          (e.is_a?(::Apache::Hadoop::Hbase::Thrift::IOError) && e.message.include?("closed stream")) || 
          e.is_a?(::Thrift::TransportException) || 
          e.is_a?(::Thrift::ApplicationException)
        end

        def reconnect!(e)
          close
          sleep 1
          @transport = nil
          @client = nil
          open(:reconnecting => true, :reason => e.class)
        end

        # Pick up a host:
        # - host
        # or
        # - host part of the hosts pool
        def populateCurrentHost
          if host.present?
            self.current_host = host
          else
            hosts_to_pick = hosts.clone
            hosts_to_pick.delete(current_host)
            self.current_host = hosts_to_pick.sample
          end
        end
    
      end
    end
  end
end
