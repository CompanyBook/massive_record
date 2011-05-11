module MassiveRecord
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "massive_record.logger" do
        MassiveRecord::ORM::Base.logger = ::Rails.logger
      end

      initializer "massive_record.action_dispatch" do
        ActiveSupport.on_load :action_controller do
          ActionDispatch::ShowExceptions.rescue_responses.update('MassiveRecord::ORM::RecordNotFound' => :not_found)
        end
      end
    end
  end
end
