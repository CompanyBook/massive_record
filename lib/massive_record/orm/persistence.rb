module MassiveRecord
  module ORM
    module Persistence
      # Basic persistence methods - Needs to be implemented. Needed them
      # for wrapping callbacks around them. At least I think I need them now ;-)
      %w(save save! create create! destroy delete).each do |method|
        define_method(method) do
          true
        end
      end
    end
  end
end
