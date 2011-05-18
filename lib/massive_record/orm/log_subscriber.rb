module MassiveRecord
  module ORM
    class LogSubscriber < ActiveSupport::LogSubscriber
      def query(event)
        return unless logger.debug?

        payload = event.payload
        name = '%s (%.1fms)' % [payload[:name], event.duration]

        debug "  " + [name, payload[:description]].compact.join("  ")
      end

      def logger
        MassiveRecord::ORM::Base.logger
      end
    end

    LogSubscriber.attach_to :massive_record
  end
end
