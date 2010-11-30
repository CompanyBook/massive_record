require 'active_model'
require 'massive_record/orm/validations'

module MassiveRecord
  module ORM
    class Base
    
      include Validations
    end
  end
end

require 'massive_record/orm/table'
require 'massive_record/orm/column'
