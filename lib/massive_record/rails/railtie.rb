module MassiveRecord
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "massive_record.logger" do
        MassiveRecord::ORM::Base.logger = ::Rails.logger
      end

      # Make Rails handle RecordNotFound correctly in production
      initializer "massive_record.action_dispatch" do
        ActiveSupport.on_load :action_controller do
          ActionDispatch::ShowExceptions.rescue_responses.update('MassiveRecord::ORM::RecordNotFound' => :not_found)
        end
      end

      # Expose database runtime to controller for logging.
      initializer "massive_record.log_runtime" do
        require "massive_record/rails/controller_runtime"
        ActiveSupport.on_load(:action_controller) do |app|
          include MassiveRecord::Rails::ControllerRuntime
        end
      end
    end
  end
end
