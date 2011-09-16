require 'massive_record/orm/schema/embedded_interface'

module MassiveRecord
  module ORM
    class Embedded < Base
      include Schema::EmbeddedInterface

      # TODO  Embedded does not support these kind of methods
      class << self
        undef_method :first, :last, :all, :exists?, :destroy_all
      end
    end
  end
end
