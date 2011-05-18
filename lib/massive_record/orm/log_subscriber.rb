module MassiveRecord
  module ORM
    class LogSubscriber < ActiveSupport::LogSubscriber
      def query(event)
        return unless logger.debug?

        payload = event.payload
        name = '%s (%.1fms)' % [payload[:name], event.duration]
        description = payload[:description]

        if odd?
          name = color(name, CYAN, true)
          description = color(description, nil, true)
        else
          name = color(name, MAGENTA, true)
        end

        debug "  " + [name, description].compact.join("  ")
      end

      def logger
        MassiveRecord::ORM::Base.logger
      end


      private

      def odd?
        @odd = !@odd
      end
    end

    LogSubscriber.attach_to :massive_record
  end
end
