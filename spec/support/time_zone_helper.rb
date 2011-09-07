module TimeZoneHelper
  #
  # Helper method which enables and disables time zone awareness and sets the
  # incomming time zone to the current one.
  #
  # Method will ensure that everything is put back into
  # the state it was before the method was called.
  #
  def in_time_zone(zone)
    old_zone = Time.zone
    old_awareness = MassiveRecord::ORM::Base.time_zone_aware_attributes
    MassiveRecord::ORM::Base.descendants.each { |klass| klass.undefine_attribute_methods } # If time zone awareness has changed we need to re-generate methods


    Time.zone = zone ? ActiveSupport::TimeZone[zone] : nil
    MassiveRecord::ORM::Base.time_zone_aware_attributes = !zone.nil?

    yield

    ensure
      Time.zone = old_zone
      MassiveRecord::ORM::Base.time_zone_aware_attributes = old_awareness
      MassiveRecord::ORM::Base.descendants.each { |klass| klass.undefine_attribute_methods } # If time zone awareness has changed we need to re-generate methods
  end
end
