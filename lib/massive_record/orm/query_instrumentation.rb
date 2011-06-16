module MassiveRecord
  module ORM
    module QueryInstrumentation
      extend ActiveSupport::Concern

      module ClassMethods
        #
        # do_find is the method which *all* find operations goes
        # through. For instrumentation on the query only see
        # hbase_query_all_first /hbase_query_find
        #
        def do_find(*args)
          ActiveSupport::Notifications.instrument("load.massive_record", {
            :name => [model_name, 'load'].join(' '),
            :description => "",
            :options => args
          }) do
            super
          end
        end




        private

        def hbase_query_all_first(type, *args)
          ActiveSupport::Notifications.instrument("find_query.massive_record", {
            :name => [model_name, 'query'].join(' '),
            :description => type,
            :options => args
          }) do
            super
          end
        end

        def hbase_query_find(what_to_find, options)
          ActiveSupport::Notifications.instrument("find_query.massive_record", {
            :name => [model_name, 'query'].join(' '),
            :description => "find id(s): #{what_to_find}",
            :options => options
          }) do
            super
          end
        end
      end


      private

      def store_record_to_database(action, attribute_names_to_update = [])
        description = action + " id: #{id},"
        description += " attributes: #{attribute_names_to_update.join(', ')}" if attribute_names_to_update.any?

        ActiveSupport::Notifications.instrument("query.massive_record", {
          :name => [self.class.model_name, 'save'].join(' '),
          :description => description
        }) do
          super
        end
      end
    end
  end
end
