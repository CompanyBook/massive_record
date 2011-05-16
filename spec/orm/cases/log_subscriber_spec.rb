require 'spec_helper'
require "active_support/log_subscriber/test_helper"

describe "log subscriber" do
  include MockMassiveRecordConnection

  subject { ActiveSupport::LogSubscriber::TestHelper::MockLogger.new }

  before do
    @old_logger = MassiveRecord::ORM::Base.logger
    @notifier = ActiveSupport::Notifications::Fanout.new

    ActiveSupport::LogSubscriber.colorize_logging = false

    MassiveRecord::ORM::Base.logger = subject
    ActiveSupport::Notifications.notifier = @notifi
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
  end


  context "info" do
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
