# v0.2.0.beta3 (git develop)

- You can now disallow nil values, and in that case we will ensure that given field has its default value.
- Rails will now handle MassiveRecord::ORM::RecordNotFound correctly in a production environment, rendering 404.


# v0.2.0.beta2 (git master)

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
