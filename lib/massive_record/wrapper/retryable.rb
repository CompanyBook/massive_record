#
# Some application like a Rails website will reload the environment and initiate 
# a new connection if HBase / Thrift is going down.
# In the case of a plain Ruby application running as a daemon, the same error could
# shutdown your application. This class helps you to keep trying if you loose the 
# connection with Thrift.
# The exception Apache::Hadoop::Hbase::Thrift::IOError will be catched and the 
# block inside will be tried again.
#
# Retryable.new do
#   message = Message.new
#   message.save
# end 
#
module MassiveRecord
  module Wrapper
    class Retryable
      
      attr_accessor :exception_to_retry, :max_retry_count, :current_retry_count, :sleep_in_seconds, :logger

      #
      # Options:
      # on     => Class of the Exception, Apache::Hadoop::Hbase::Thrift::IOError by default
      # retry  => Maximum amount of time the code is trying to run
      # logger => Initialized Ruby Logger object
      #
      def initialize(opts = {}, &block)
        raise "The Retryable class needs a block to be initialized." unless block_given?

        @exception_to_retry  = opts[:on]    || Exception
        @max_retry_count     = opts[:retry] || 50
        @current_retry_count = 0
        @sleep_in_seconds    = 2
        @logger              = opts[:logger]

        begin
          return yield
        rescue exception_to_retry
          self.current_retry_count += 1
          if current_retry_count <= max_retry_count
            sleep_before_retry
            retry
          end
        end

        yield
      end

      #
      # The sleeping period is increasing exponentially
      # 1 try   : 2 seconds
      # 2 tries : 4 seconds
      # 3 tries : 8 seconds
      # 4 tried : 16 seconds
      # ...
      #
      def sleep_before_retry
        time = sleep_in_seconds ** current_retry_count
        time = 3600 if time > 3600
        logger.info "Exception < #{exception_to_retry.to_s} > raised... waiting #{time} seconds before retry." if logger
        sleep(time)
      end
      
    end  
  end
end
