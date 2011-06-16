module MassiveRecord
  module ORM
    class LogSubscriber < ActiveSupport::LogSubscriber
      def self.runtime=(value)
        Thread.current["massive_record_query_runtime"] = value
      end

      def self.runtime
        Thread.current["massive_record_query_runtime"] ||= 0
      end

      def self.reset_runtime
        rt, self.runtime = runtime, 0
        rt
      end
      


      def load(event)
        self.class.runtime += event.duration

        return unless logger.debug?

        payload = event.payload
        name = '%s (%.1fms)' % [payload[:name], event.duration]
        description = payload[:description]
        options = payload[:options]

        if options.present? && options.any?
          options = "options: #{options}"
        else
          options = nil
        end

        if odd?
          name = color(name, CYAN, true)
          description = color(description, nil, true)
        else
          name = color(name, MAGENTA, true)
        end

        debug "  " + [name, description, options].compact.join("  ")
      end

      def query(event)
        return unless logger.debug?

        payload = event.payload
        name = '%s (%.1fms)' % [payload[:name], event.duration]
        description = payload[:description]
        options = payload[:options]

        if options.present? && options.any?
          options = "options: #{options}"
        else
          options = nil
        end

        if odd?
          name = color(name, CYAN, true)
          description = color(description, nil, true)
        else
          name = color(name, MAGENTA, true)
        end

        debug "  " + [name, description, options].compact.join("  ")
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
