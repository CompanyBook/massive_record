require 'spec_helper'


class PersonObserver < MassiveRecord::ORM::Observer
  [:after_create].each do |observer|
    define_method observer do |person|
      send("calls_to_#{observer}") << person
    end

    define_method "calls_to_#{observer}" do
      instance_variable_get("@calls_to_#{observer}") or
      instance_variable_set("@calls_to_#{observer}", [])
    end
  end
end

class AuditObserver < MassiveRecord::ORM::Observer
  observe :test_class
  
  def changes_log
    @changes_log ||= []
  end

  def after_save(record)
    changes_log << record.changes
  end
end


describe "Observers" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  context "when having an implicit target" do
    subject { PersonObserver.instance }
    before { subject } # Tap to initialize observer

    it "calls after_save on observer" do
      person_1 = Person.create! name: "Thorbjorn Hermansen", age: 30 
      person_2 = Person.create! name: "Thorbjorn Hermansen", age: 30 
      
      subject.calls_to_after_create.should eq [person_1, person_2]
    end
  end

  context "having an explicit target" do
    subject { AuditObserver.instance }
    before { subject } # Tap to initialize observer

    it "logs changes to the test class" do
      test = TestClass.create! :foo => 'bar'
      subject.changes_log.clear

      test.foo = 'barbar'
      changes = test.changes
      test.save!

      subject.changes_log.should eq [changes]
    end
  end
end
