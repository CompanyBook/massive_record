require 'spec_helper'
require 'orm/models/person'

describe "mass assignment security" do
  def restore_mass_assignment_security_policy_after(klass)
    accessible_attributes = klass._accessible_attributes
    protected_attributes = klass._protected_attributes
    active_authorizer = klass._active_authorizer

    yield

    klass._accessible_attributes = accessible_attributes
    klass._protected_attributes = protected_attributes
    klass._active_authorizer = active_authorizer
  end



  describe "settings and defaults" do
    subject { Person }
    its(:attributes_protected_by_default ) { should include 'id', Person.inheritance_attribute }
    its(:protected_attributes) { should include 'id', Person.inheritance_attribute }


    describe "#attr_accessible" do
      it "sets attributes accessible" do
        restore_mass_assignment_security_policy_after Person do
          Person.class_eval do
            attr_accessible :age
          end

          Person.accessible_attributes.should include 'age'
        end
      end
    end

    describe "#attr_protected" do
      it "sets attributes protected" do
        restore_mass_assignment_security_policy_after Person do
          Person.class_eval do
            attr_protected :age
          end

          Person.protected_attributes.should include 'age'
        end
      end
    end
  end

  describe "access test on" do
    describe Person do
      context "when only age is accessible" do
        it "sets age with mass assignment" do
          restore_mass_assignment_security_policy_after Person do
            Person.class_eval do
              attr_accessible :age
            end

            Person.new(:age => 33).age.should eq 33
          end
        end

        it "does not set name with mass assignment" do
          restore_mass_assignment_security_policy_after Person do
            Person.class_eval do
              attr_accessible :age
            end

            Person.new(:name => 'Thorbjorn').name.should be_nil
          end
        end
      end

      context "when only age is protected" do
        it "does not set age with mass assignment" do
          restore_mass_assignment_security_policy_after Person do
            Person.class_eval do
              attr_protected :age
            end

            Person.new(:age => 33).age.should be_nil
          end
        end

        it "sets name with mass assignment" do
          restore_mass_assignment_security_policy_after Person do
            Person.class_eval do
              attr_protected :age
            end

            Person.new(:name => 'Thorbjorn').name.should eq "Thorbjorn"
          end
        end
      end
    end
  end
end
