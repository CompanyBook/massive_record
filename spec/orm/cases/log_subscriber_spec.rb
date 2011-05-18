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
    ActiveSupport::Notifications.notifier = @notifi

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

    it "should have one lined log to debug when doing a all" do
      Person.all
      wait
      subject.logged(:debug).size.should eq 1
    end

    it "should include a the class name of what is loading, time it took, a description about what has been done" do
      Person.all
      wait
      subject.logged(:debug).first.should match /Person.+?load.+?([\d.]+).+?all/
    end

    it "should include class, time and description on first" do
      Person.first
      wait
      subject.logged(:debug).first.should match /Person.+?load.+?([\d.]+).+?all.+?options.+?limit=>1/
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
