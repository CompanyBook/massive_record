module MassiveRecord
  module ORM
    class LogSubscriber < ActiveSupport::LogSubscriber
      def query(event)
        return unless logger.debug?
        name = '%s (%.1fms)' % [event.payload[:name], event.duration]
        debug "  #{name}"
      end

      def logger
        MassiveRecord::ORM::Base.logger
      end
    end

    LogSubscriber.attach_to :massive_record
  end
end
