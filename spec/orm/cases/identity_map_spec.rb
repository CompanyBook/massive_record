require 'spec_helper'

describe MassiveRecord::ORM::IdentityMap do
  describe "confirguration" do
    subject { described_class }
    
    describe ".enabled" do
      context "when disabled" do
        its(:enabled) { should be_false }
        its(:enabled?) { should be_false }
      end

      context "when enabled" do
        before { MassiveRecord::ORM::IdentityMap.enabled = true }
        its(:enabled) { should be_true }
        its(:enabled?) { should be_true }
      end
    end
  end
end
