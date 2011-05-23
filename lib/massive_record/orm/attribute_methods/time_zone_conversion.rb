module MassiveRecord
  module ORM
    module AttributeMethods

      #
      # Module for handling time zones
      #
      # Related attributes and configurations:
      #   Base.default_timezone                         
      #     is the zone persisted in the database
      #   Base.time_zone_aware_attributes
      #     is flag for disable / enable it altogether
      #   Base.skip_time_zone_conversion_for_attributes
      #     makes it possible to skip specific conversions on given attributes
      #
      #
      module TimeZoneConversion
        extend ActiveSupport::Concern

        included do
          # Determines whether to use Time.local (using :local) or Time.utc (using :utc)
          # when pulling dates and times from the database. This is set to :local by default.
          cattr_accessor :default_timezone, :instance_writer => false
          self.default_timezone = :local

          cattr_accessor :time_zone_aware_attributes, :instance_writer => false
          self.time_zone_aware_attributes = false

          class_attribute :skip_time_zone_conversion_for_attributes, :instance_writer => false
          self.skip_time_zone_conversion_for_attributes = []
        end
      end
    end
  end
end
