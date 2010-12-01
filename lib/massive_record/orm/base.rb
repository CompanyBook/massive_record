require 'active_model'
require 'massive_record/orm/attributes'
require 'massive_record/orm/validations'
require 'massive_record/orm/naming'
require 'massive_record/orm/column_family'

module MassiveRecord
  module ORM
    class Base
    
      # START OF TEMP CODE
      #   FIXME - The following code is just added to make tests of validations etc pastt
      #           It cam be removed / refactored when the DSL for setting up columns etc
      #           are in place.

      def initialize(attributes = {})
        attributes.each do |attribute, value|
          class_eval { attr_accessor attribute }
          send("#{attribute}=", value)
        end
      end

      # END OF TEMP CODE

      include ActiveModel::Translation
      include Attributes
      include Validations
      include Naming      
    end
  end
end

require 'massive_record/orm/table'
require 'massive_record/orm/column'
