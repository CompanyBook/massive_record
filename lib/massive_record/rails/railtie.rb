module MassiveRecord
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "massive_record.logger" do
        MassiveRecord::ORM::Base.logger = ::Rails.logger
      end
    end
  end
end
