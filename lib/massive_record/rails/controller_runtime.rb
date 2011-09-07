module MassiveRecord
  module Rails
    #
    # Included into action controller to play nice with 
    # actionpack/lib/action_controller/metal/instrumentation
    #
    # log_process_action is the real heart of this module; injecting
    # the time it took for database queries to complete.
    #
    module ControllerRuntime
      extend ActiveSupport::Concern

      

      protected

      attr_internal :db_runtime

      def process_action(action, *args)
        # We also need to reset the runtime before each action
        # because of queries in middleware or in cases we are streaming
        # and it won't be cleaned up by the method below.
        MassiveRecord::ORM::LogSubscriber.reset_runtime
        super
      end


      def cleanup_view_runtime
        db_rt_before_render = MassiveRecord::ORM::LogSubscriber.reset_runtime
        runtime = super
        db_rt_after_render = MassiveRecord::ORM::LogSubscriber.reset_runtime
        self.db_runtime = db_rt_before_render + db_rt_after_render
        runtime - db_rt_after_render
      end
      


      def append_info_to_payload(payload)
        super
        payload[:db_runtime] = db_runtime
      end




      module ClassMethods
        def log_process_action(payload)
          messages, db_runtime = super, payload[:db_runtime]
          messages << ("MassiveRecord: %.1fms" % db_runtime.to_f) if db_runtime
          messages
        end
      end
    end
  end
end
