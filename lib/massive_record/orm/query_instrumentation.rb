module MassiveRecord
  module ORM
    module QueryInstrumentation
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def hbase_query_all_first(type, *args)
          ActiveSupport::Notifications.instrument("query.massive_record", {
            :name => [model_name, 'load'].join(' '),
            :description => type,
            :options => args
          }) do
            super
          end
        end

        def hbase_query_find(what_to_find, options)
          ActiveSupport::Notifications.instrument("query.massive_record", {
            :name => [model_name, 'load'].join(' '),
            :description => "find id(s): #{what_to_find}",
            :options => options
          }) do
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
