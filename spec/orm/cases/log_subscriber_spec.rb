require 'spec_helper'
require "active_support/log_subscriber/test_helper"

describe "log subscriber" do
  include ActiveSupport::BufferedLogger::Severity

  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  let(:level) { DEBUG }
  subject { ActiveSupport::LogSubscriber::TestHelper::MockLogger.new(level) }

  before do
    @old_logger = MassiveRecord::ORM::Base.logger
    @notifier = ActiveSupport::Notifications::Fanout.new

    ActiveSupport::LogSubscriber.colorize_logging = false

    MassiveRecord::ORM::Base.logger = subject
    ActiveSupport::Notifications.notifier = @notifier

    MassiveRecord::ORM::LogSubscriber.attach_to :massive_record
  end

  after do
    MassiveRecord::ORM::Base.logger = @old_logger
    ActiveSupport::Notifications.notifier = nil
  end



  context "debug" do
    it "should have nothing loged to begin with" do
      subject.logged(:debug).size.should be_zero
    end


    describe "loading records" do
      it "should have one lined log to debug when doing a all" do
        Person.all
        wait
        subject.logged(:debug).size.should eq 2
      end

      it "should include a the class name of what is loading, time it took, a description about what has been done" do
        Person.all
        wait
        subject.logged(:debug).last.should match /Person.+?load.+?([\d.]+).+?all/
      end
    end

    describe "querying records" do
      it "should have one lined log to debug when doing a all" do
        Person.all
        wait
        subject.logged(:debug).size.should eq 2
      end

      it "should include a the class name of what is querying, time it took, a description about what has been done" do
        Person.all
        wait
        subject.logged(:debug).first.should match /Person.+?query.+?([\d.]+).+?all/
      end

      it "should include class, time and description on first" do
        Person.first
        wait
        subject.logged(:debug).first.should match /Person.+?query.+?([\d.]+).+?all.+?options.+?limit=>1/
      end

      it "should include id when finding one person" do
        Person.exists? "id_to_be_found"
        wait
        subject.logged(:debug).first.should include "id(s): id_to_be_found"
      end

      it "should not see the options hash if it's empty" do
        Person.exists? "id_to_be_found"
        wait
        subject.logged(:debug).first.should_not include "{}"
      end
    end
    
    describe "store records" do
      before do
        @person = Person.create! :id => "first", :name => "Name", :age => 20
        wait
      end

      describe "create" do
        it "should have one line log when creating a record" do
          subject.logged(:debug).size.should eq 1
        end

        it "should include class of what is being save, time it took an what kind of save it was" do
          subject.logged(:debug).first.should match /Person.+?save.+?([\d.]+).+?create/
        end
      end

      describe "update" do
        before do
          # Resetting the logger. Kinda hackish, might break if MockLogger changes internal implementation
          subject.instance_variable_set(:@logged, Hash.new { |h,k| h[k] = [] })
          @person.name = "New Name"
          @person.save!
        end

        it "should have one line log when updating a record" do
          subject.logged(:debug).size.should eq 1
        end

        it "should include class of what is being save, time it took an what kind of save it was" do
          subject.logged(:debug).first.should match /Person.+?save.+?([\d.]+).+?update.+?id: first/
        end

        it "should include a list of attributes which was updated" do
          subject.logged(:debug).first.should match /attributes: name/
        end
      end
    end
  end


  context "info" do
    let(:level) { INFO }

    it "should have nothing logged to begin with" do
      subject.logged(:debug).size.should be_zero
    end

    it "should have nothing logged when doing an all call" do
      Person.all
      wait
      subject.logged(:debug).size.should be_zero
    end
  end




  private

  def wait
    @notifier.wait
  end
end
