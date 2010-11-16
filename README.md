# Massive Record

HBase API and ORM using the HBase Thrift API.


## TODO

  * code documentation
  * Rails ORM (ActiveModel etc.)
  * rows update / delete methods
  * write tests
  * add generators for hbase.yml etc.
  * add migration tools
  * ...


## Requirements

  * Thrift Gem 0.5.0
  * The Thrift library used has been tested with hbase-0.89.20100924.


## Terms to know

See introduction to HBase model architecture :  
http://wiki.apache.org/hadoop/Hbase/HbaseArchitecture

Understanding terminology of Table / Row / Column family / Column / Cell :  
http://jimbojw.com/wiki/index.php?title=Understanding_Hbase_and_BigTable


## Installation

### IRB

Install the Ruby thrift library :

    gem install thrift
    
Checkout the massive_record project and install it as a Gem :

    git clone git@github.com:CompanyBook/massive_record.git
    cd massive_record/
    rake install massive_record.gemspec
    
Then in IRB :

    require 'rubygems'
    require 'massive_record'
    
    conn = MassiveRecord::Connection.new(:host => 'localhost', :port => 9090)
    
### Ruby on Rails

    # Checkout the massive_record project :
    git clone git@github.com:CompanyBook/massive_record.git
    # The absolute path /etc/massive_record need to link to the project :
    ln -s /my/path/to/massive_record /etc/massive_record
    
Add the following Gems in your Gemfile :
    
    gem 'thrift', '0.5.0'
    gem 'massive_record', :path => '/etc/massive_record'

Create an config/hbase.yml file with the following content :
  
    defaults: &defaults
      user: hbase
      host: somewhere.compute.amazonaws.com
      port: 9090

    development:
      <<: *defaults

    test:
      <<: *defaults
      <<: *development

    production:
      <<: *defaults


## Thrift API

Ruby Library using the HBase Thrift API.
http://wiki.apache.org/hadoop/Hbase/ThriftApi

The generated Ruby files can be found under lib/massive_record/thrift/  
The whole API (CRUD and more) is present in the Client object (Apache::Hadoop::Hbase::Thrift::Hbase::Client).  
The client can be easily initialized using the MassiveRecord connection :

    conn = MassiveRecord::Connection.new(:host => 'localhost', :port => 9090)
    conn.open
    
    client = conn.client
    # Do whatever you want with the client object
    

## Ruby API

Thrift API wrapper :
  
    # Init a new connection with HBase
    conn = MassiveRecord::Connection.new(:host => 'localhost', :port => 9090)
    conn.open
    
    # OR init a connection using the config/hbase.yml file with Rails
    conn = MassiveRecord::Base.connection
  
    # Fetch tables name
    conn.tables # => ["companies", "news", "webpages"]
  
    # Init a table
    table = MassiveRecord::Table.new(conn, :people)
  
    # Add a column family
    column = MassiveRecord::ColumnFamily.new(:info)
    table.column_families.push(column)
  
    # Create the table
    table.save
  
    # Fetch column families from the database
    table.fetch_column_families # => [ColumnFamily#RTY23423424]
    table.column_families.collect(&:name) # => ["info"]
  
    # Add a new row
    row = Row.new
    row.key = "my_unique_key"
    row.values = { "info:first_name" => "H", "info:last_name" => "Base", "info:email" => "h@base.com" }
    row.table = table
    row.save
  
    # Fetch rows
    table.first # => MassiveRecord#erg98453456
    table.all(limit: 10) # [MassiveRecord#erg9233456, MassiveRecord#erg98453456, ...]
  
  
## Rails ORM - NOT working yet

    class Person < MassiveRecord::Base.table
    
      column_family :info
      column_family :websites
      column_family :address, Address
    
      alias_attribute :first_name,   'info:first_name'
      alias_attribute :last_name,    'info:last_name'
      alias_attribute :email,        'info:email'
      alias_attribute :phone_number, 'info:phone_number'
    
    end
  
    class Address < MassiveRecord::Base.column_family
    
      belongs_to :person
    
      def simple_format
        "#{self.person.first_name} #{self.person.last_name} - #{self.street_address}, #{self.city}, #{self.country}"
      end
    
      def phone_number
        self.person.phone_number
      end
    
    end
  
    # New record
    p = Person.new
    p.first_name = "John"
    p.email = "hbase@companybook.no"
    p.address = Address.new(street_address: "Philip Pedersensver 1", city: "Oslo", country: "Norway")
    p.save
  
    # Find
    p = Person.find("my_person_id")
    p.first_name # => John
    p.address # => Address#s5645645
    p.address.simple_format # => "John - Philip Pedersensver 1, Oslo, Norway"
    
    # Delete
    p.destroy
  

Copyright (c) 2010 Companybook, released under the MIT license