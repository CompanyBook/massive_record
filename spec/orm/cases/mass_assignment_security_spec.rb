require 'spec_helper'
require 'orm/models/person'

describe "mass assignment security" do
  describe "settings and defaults" do
    subject { Person }
    its(:attributes_protected_by_default ) { should include 'id', Person.inheritance_attribute }
    its(:protected_attributes) { should include 'id', Person.inheritance_attribute }
  end

  describe "access test on" do
    describe Person do

    end
  end
end
