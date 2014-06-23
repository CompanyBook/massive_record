require 'active_support/notifications'

module MassiveRecord
  module Adapters
    module Thrift
      class Connection
  
        attr_accessor :host, :hosts, :port, :timeout, :current_host, :tables_collection
    
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
          return @tables_collection unless @tables_collection.nil?
          @tables_collection ||= MassiveRecord::Wrapper::TablesCollection.new
          @tables_collection.connection = self
          (getTableNames() || {}).each{|table_name| @tables_collection.push(table_name)}
          @tables_collection
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
          @instrumenter.instrument "adapter_query.massive_record", { :method_name => method } do
            begin
              expire_tables_collection_if_needed(method)
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

        # The connection is caching the list of tables
        # We need to expire the list if one is added/removed
        def expire_tables_collection_if_needed(method_name)
          if ["createTable", "deleteTable"].include?(method_name)
            self.tables_collection = nil
          end
        end
    
      end
    end
  end
end
