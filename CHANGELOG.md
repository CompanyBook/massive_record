# v0.2.2 (git develop)


# v0.2.1 (git master)

- Models without any default_id will now by default get an id via next_id(). You can turn it off
  via the setting auto_increment_id on ORM::Base or on the Model class itself.
- record.reload now resets relations.
- If you have a persisted record and you set one attribute to nil that attribute will be
  deleted from HBase to represent the nil-value. The fact that the schema of that record
  class knows of that attribute will be the reason for it to still respond and return nil.
- Thrift adapter will no longer return UTF-8 encoded strings. The reason for this is that
  binary representation of integers cannot be set with a UTF-8 encoding; it must be BINARY.
  It is the client`s responsibility of the adapter to set correct encoding, and the ORM now
  does this too.
- If you do have a database where integers are stored as string, you should enable
  ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings. It will, before for
  instance atomic_increment! is called, ensure that the integers has been persisted as hex.
- Based on the previous change we are now able to do real atomic incrementation of integer values.
  HBase will do the incrementation and guarantee the integrity of that incrementation.
- Fixnum and Bignum are stored as a 64 bit signed integer representation, not as strings. Fixnum and bignum
  values are no longer encoded by the ORM; that responsibility has been moved down to the adapter.
- We can now, by setting Base.check_record_uniqueness_on_create to true, do a quick and simple (and
  kinda insecure) check if the record id exists on a new_record when doing a create call. Just a simple sanity check.
- We now have mass assignment of attributes, just like ActiveRecord. It uses the same module,
  so attr_accessible and attr_protected methods are available. By default the id and inheritable attribute
  are protected. If you where doing Person.new(:id => 'ID') you might want to change this now as it will no
  longer work.
- Ids can now be assigned on new/create/create! with: Person.new("id", attributes). Person.new(id: "id") will
  is soon to be disallowed.
- Polymorphic type attribute is no longer called underscore on. Should be backwards compatible when finding records.
- Time can now be time zone aware. Times are being presented in the Time.zone, and persisted 
  in UTC. You enable it with MassiveRecord::ORM::Base.time_zone_aware_attributes = true.
  In a Rails application this will be set to true by default.
- No longer checking if table exist on a find. Instead we rescue error the few times a table does not exist,
  and create it based on current schema. This gained a lot of speed on our production server.
- Changed the way Thrift::Table executes find(). It is now doing the work ~3 times faster.
- In Rails, we are now included in the 200-ok-completed-log like: Completed 200 OK in 798ms (Views: 277.5ms | MassiveRecord: 9.2ms)
- Subscribed to events from query instruments and printing out time spent in database per call.
- Added ActiveSupport Notifications instruments around database query calls in the ORM level.
- Removed inclusion of ActiveModel::Translation in ORM::Base class, as including ActiveModel::Validations
  extends ORM::Base with Translation as well (and it should never have been included; it should have been extended with..)

# v0.2.0

- Intersection and union operations on arrays containing MassiveRecord objects is now working as expected.
- You can now disallow nil values, and in that case we will ensure that given field has its default value.
- Rails will now handle MassiveRecord::ORM::RecordNotFound correctly in a production environment, rendering 404.
- record.attributes no longer returns internal @attributes-hash directly. Instead it iterates over all attributes,
  fetches their values through read_attribute and then returns a new hash with these attribute-name-values pairs.
- Fixed problem with STI sub classes in Rails development environment: Attributes defined in a sub class
  was not loaded correctly first time you loaded a record through its parent class.

# v0.2.0.beta2

- We are now raising error if MassiveRecordClass.new(attributes) receives unknown attributes.
- Added support for Record.new(:references_many => [record, record]) and a_record.references_many = [record, record]



# v0.2.0.beta

- ORM will now take care of serialize and de-serialize of attributes like arrays, hashes etc. It is doing so
  based on the type of your fields. You can select either JSON or YAML serialization for your data. As a default it
  will use JSON. You can also, by chaining multiple coders together add support for multiple serialization types
  when reading data from the database.
- Thrift-adapter will no longer auto-serialize objects likes hashes and arrays. Its vlaues must now be strings, and it
  will only take care of encoding/decoding it to and from what Thrift expects (binary encoding).
- Compare Person === proxy_targeting_a_person will now be true. Makes case-when-constructions doable.
- Single table inheritance is supported. By default you can have an attribute called type to give you support for it in a table.
- A default_scope is possible to set on classes. For instance: Calling default_scope select(:only_this_column_family)
  inside of a class will execute finder operations with this as default scope. If you need to fetch records of class
  without your preset default scope you can use Model.unscoped.
- We now have some ActiveRecord like chaining of method calls when we do find-operations. Like Person.select(:column_family).limit(2)
  is the same as Person.all(:select => ['column_family', :limit => 2])
- references_many has first() and limit() which uses the target array if loaded, or load only what it needs from the database.
- Wrapper::Thrift has been moved into Adapter::Thrift. Adding more adapters should be not that hard now.
- References many is now possible. We have to strategies: Store an array of foreign keys in the proxy_owner,
  or supply a ids-starts-with and open up a scanner and read from that point.
- Setting a non-parsable value on date/time field will no longer raise an error.
- Scanner no longer fetches with a limit of 10 by default. It is set to 100000000.
- References one relations support polymorphic relations.
- Simple implementation of references_one relation. This is where you have a foreign key you will look up in a different table.



# v0.1.2
- Fixed, or at least made better, the is_yaml? method in Wrapper::Cell.This functionality of serialize/de-serialize
  should be moved up into the ORM asap, but for now a hot fix has been applied.



# v0.1.1

- A ORM record now now if it is read only or not.
- Added a logger to ORM::Base, which is set to Rails.logger if gem is used with Rails.
- The database cleaner will no longer destroy tables, only delete all of their contents between tests. Speed tests up a lot.
- known_attribute_names are now available as instance method as well.
- If you add a created_at attribute it will be maintained by the ORM with the time the object was created.
- An adapter (wrapper) row now has an updated_at attribute. ORM objects also responds to updated_at
- Bugfix: Database cleaner no longer tries to remove tables with same name twice.



# v0.1.0

- Communication with Hbase via Thrift.
- Basic ORM capabilities.
