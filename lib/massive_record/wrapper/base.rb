require 'yaml'

require 'massive_record/wrapper/adapter'
require 'massive_record/wrapper/errors'
require 'massive_record/wrapper/tables_collection'
require 'massive_record/wrapper/column_families_collection'
require 'massive_record/wrapper/cell'
require 'massive_record/wrapper/retryable'

module MassiveRecord
  module Wrapper
    class Base
      
      def self.config
        config = YAML.load_file(::Rails.root.join('config', 'hbase.yml'))[::Rails.env]
        { 
          :host => config['host'], 
          :hosts => config['hosts'], 
          :port => config['port'], 
          :timeout => config['timeout'] 
        }
      end

      def self.connection(opts = {})
        conn = ADAPTER::Connection.new(opts.empty? ? config : opts)
        conn.open
        conn
      end
      
    end
  end
end
