require 'spec_helper'
require 'orm/models/friend'
require 'orm/models/best_friend'

describe "Single table inheritance" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  describe Friend do
    let(:subject) { Friend.new :id => "ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true }
  end


end
