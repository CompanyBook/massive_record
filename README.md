# Massive Record

Massive Record is an ORM for HBase. It currently uses
Thrift to communicate with HBase and will in time support
other forms for communicating with Hbase.


See introduction to HBase model architecture:  
http://wiki.apache.org/hadoop/Hbase/HbaseArchitecture  
Understanding terminology of Table / Row / Column family / Column / Cell:  
http://jimbojw.com/wiki/index.php?title=Understanding_Hbase_and_BigTable


## Installation

First of all: Please make sure you are using Ruby 1.9.2. For now, we are only ensuring
that Massive Record works on that Ruby version, and we know it has some problems with 1.8.7.

  gem install massive_record

### Ruby on Rails
    
Add the following Gems in your Gemfile:
    
    gem 'massive_record'

Create an config/hbase.yml file with the following content:
  
    defaults: &defaults
      host: somewhere.compute.amazonaws.com # No 'http', it's a Thrift connection
      port: 9090

    development:
      <<: *defaults

    test:
      <<: *defaults

    production:
      <<: *defaults


## Usage

There are two ways for using the Massive Record library. At the highest level we have ORM. This is Active Model compliant and makes
it easy to use. The second way of doing things is working directly against the wrapper (soon to be called adapter).


### ORM
    
Both MassiveRecord::ORM::Table and MassiveRecord::ORM::Column do now have some functionality which you can expect from an ORM. This includes:
    - An initializer which takes attribute hash and assigns them to your object.
    - Write and read methods for the attributes
    - Validations, as you expect from an ActiveRecord.
    - Callbacks, as you expect from an ActiveRecord.
    - Information about changes on attributes.
    - Casting of attributes
    - Serialization of array / hashes
    - Timestamps like created_at and updated_at. Updated at will always be available, created_at must be defined. See example down:
    - Finder scopes. Like: Person.select(:only_columns_from_this_family).limit(10).collect(&:name)
    - Ability to set a default scope.
    - Time zone aware time attributes.
    - Basic instrumentation and logging of query times.
    - Attribute mass assignment security.

Tables also have:
    - Persistencey method calls like create, save and destroy (but they do not actually save things to hbase)
    - Easy access to adapter's connection via Person.connection
    - Easy access to adapter's hbase table via Person.table
    - Finder method, like Person.find("an_id"), Person.find("id1", "id2"), Person.all etc
    - Save / update methods
    - Auto-creation of table and column families on save if table does not exists.
    - Destroy records
    - Relations: See MassiveRecord::ORM::Relations::Interface ClassMethods for documentation


Here is an example of usage, both for Table and Column:

    class Person < MassiveRecord::ORM::Table
      references_one :boss, :class_name => "Person", :store_in => :info
      references_one :attachment, :polymorphic => true
      references_many :friends, :store_in => :info
      references_many :cars, :records_starts_from => :cars_start_id

      default_scope select(:info)

      column_family :info do
        field :name
        field :email
        field :phone_number
        field :points, :integer, :default => 0
        field :date_of_birth, :date, :allow_nil => false # Defaults to today
        field :newsletter, :boolean, :default => false
        field :type # Used for single table inheritance
        field :in_the_future, :time, :default => Proc.new { 2.hours.from_now }

        timestamps # ..or field :created_at, :time
      end

      column_family :misc do
        field :with_a_lot_of_uninteresting_data
      end

      attr_accessible :name, :email, :phone_number, :date_of_birth

      validates_presence_of :name, :email
      validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

      # Returns the id the scanner should start from in the Car table
      # to fetch cars related to this person
      def cars_start_id
        id+'-'
      end
    end

    class Friend < Person
      # This one will be stored in Person's table with it's type set to Friend.
      # Calling Person.all will return object back as a Friend.
    end

    
    
    class Address < MassiveRecord::ORM::Column
      field :street
      field :number, :integer
      field :nice_place, :boolean, :default => true
    end

You can find a small example application here: https://github.com/thhermansen/massive_record_test_app

### Related gems

We have developed some gems which adds support for MassiveRecord. These are:

#### ORM Adapter
https://github.com/CompanyBook/orm_adapter
Used by Devise. I guess we'll might release the code used to get Devise support in MR.

#### Database Cleaner
https://github.com/CompanyBook/database_cleaner
User by for instance Cucumber and ourself with Rspec.

#### Sunspot Rails
https://github.com/CompanyBook/sunspot_massive_record
Makes it easier to make things searchable with solr.


## Wrapper (adapter) API

You can, if you'd like, work directly against the adapter.
  
    # Init a new connection with HBase
    conn = MassiveRecord::Wrapper::Connection.new(:host => 'localhost', :port => 9090)
    conn.open
    
    # OR init a connection using the config/hbase.yml file with Rails
    conn = MassiveRecord::Wrapper::Base.connection
  
    # Fetch tables name
    conn.tables # => ["companies", "news", "webpages"]
  
    # Init a table
    table = MassiveRecord::Wrapper::Table.new(conn, :people)
  
    # Add a column family
    column = MassiveRecord::Wrapper::ColumnFamily.new(:info)
    table.column_families.push(column)
  
    # Or bulk add column families
    table.create_column_families([:friends, :misc])
    
    # Create the table
    table.save # will raise an exception if the table already exists
  
    # Fetch column families from the database
    table.fetch_column_families # => [ColumnFamily#RTY4424, ColumnFamily#R475424, ColumnFamily#GHJ9424]
    table.column_families.collect(&:name) # => ["info", "friends", "misc"]
  
    # Add a new row
    row = MassiveRecord::Wrapper::Row.new
    row.id = "my_unique_id"
    row.values = { :info => { :first_name => "H", :last_name => "Base", :email => "h@base.com" } }
    row.table = table
    row.save
  
    # Fetch rows
    table.first # => MassiveRecord#ID1
    table.all(:limit => 10) # => [MassiveRecord#ID1, MassiveRecord#ID2, ...]
    table.find("ID2") # => MassiveRecord#ID2
    table.find(["ID1", "ID2"]) # => [MassiveRecord#ID1, MassiveRecord#ID2]
    table.all(:limit => 3, :start => "ID2") # => [MassiveRecord#ID2, MassiveRecord#ID3, MassiveRecord#ID4]
    
    # Manipulate rows
    table.first.destroy # => true
    
    # Remove the table
    table.destroy



## Planned work

- Rename Wrapper to Adapter, and make it easy to switch from Thrift to another way of communicating with Hbase.
- Embedded objects.
- Cache the decoded values of attributes, not use the value_is_already_decoded?. This will fix possible problem with YAML as coder backend.
- Implement other Adapters, for instance using jruby and the Java API.



## Contribute

If you want to contribute feel free to fork this project :-)
Make a feature branch, write test, implement and make a pull request.

### Getting started

    git clone git://github.com/CompanyBook/massive_record.git (or the address to your fork)
    cd massive_record
    bundle install

Next up you need to add a config.yml file inside of spec/ which contains something like:
    host: url.to-a.thrift.server
    port: 9090
    table: massive_record_test_table

You should now be able to run `rspec spec/`

### Play with it in the console

Checkout the massive_record project and install it as a Gem :

    cd massive_record/
    bundle console
    ruby-1.9.2-p0 > Bundler.require
     => [
          <Bundler::Dependency type=:runtime name="massive_record" requirements=">= 0">,
          <Bundler::Dependency type=:runtime name="thrift" requirements=">= 0.5.0">,
          <Bundler::Dependency type=:runtime name="activesupport" requirements=">= 0">,
          <Bundler::Dependency type=:runtime name="activemodel" requirements=">= 0">,
          <Bundler::Dependency type=:runtime name="rspec" requirements=">= 2.1.0">
        ]
    ruby-1.9.2-p0 > MassiveRecord::VERSION
     => "0.0.1" 
    
### Clean HBase database between each test

We have created a helper module MassiveRecord::Rspec::SimpleDatabaseCleaner which, when included into rspec tests, will clean
the database for ORM records between each test case. You can also take a look into spec/support/mock_massive_record_connection.rb
for some functionality which will mock a hbase connection making it easier (faster) to test code where no real database is needed.

    


## More Information and Resources

### Thrift API

Ruby Library using the HBase Thrift API.
http://wiki.apache.org/hadoop/Hbase/ThriftApi

The generated Ruby files can be found under lib/massive_record/thrift/  
The whole API (CRUD and more) is present in the Client object (Apache::Hadoop::Hbase::Thrift::Hbase::Client).  
The client can be easily initialized using the MassiveRecord connection :

    conn = MassiveRecord::Wrapper::Connection.new(:host => 'localhost', :port => 9090)
    conn.open
    
    client = conn.client
    # Do whatever you want with the client object
    
### Q&A

How to add a new column family to an existing table?
    
    # Connect to the HBase console on the server itself and enter the following code :
    disable 'companies'
    alter 'companies', { NAME => 'new_collumn_familiy' }
    enable 'companies'


Copyright (c) 2011 Companybook, released under the MIT license
