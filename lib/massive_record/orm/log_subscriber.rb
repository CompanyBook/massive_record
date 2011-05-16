module MassiveRecord
  module ORM
    class LogSubscriber < ActiveSupport::LogSubscriber
      def query(event)
        # TODO
      end

      def logger
        MassiveRecord::ORM::Base.logger
      end
    end

    LogSubscriber.attach_to :massive_record
  end
end
