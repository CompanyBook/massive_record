# v0.2.0 (git develop)

- If you add a created_at attribute it will be maintained by the ORM with the time the object was created.
- An adapter (wrapper) row now has an updated_at attribute. ORM objects also responds to updated_at



# v0.1.1 (git master)

- Bugfix: Database cleaner no longer tries to remove tables with same name twice.



# v0.1.0

- Communication with Hbase via Thrift.
- Basic ORM capabilities.
