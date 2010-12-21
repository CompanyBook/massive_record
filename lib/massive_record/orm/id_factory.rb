require 'singleton'

module MassiveRecord
  module ORM
    class IdFactory < Table
      include Singleton
    end
  end
end
