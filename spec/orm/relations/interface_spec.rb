require 'spec_helper'

class TestRelationsInterface
  include MassiveRecord::ORM::Relations::Interface
end

describe MassiveRecord::ORM::Relations::Interface do
  describe "class methods" do
    subject { TestRelationsInterface }

    describe "should include" do
      %w(references_one).each do |relation|
        it { should respond_to relation }
      end
    end
  end
end
