require 'spec_helper'

module MassiveRecord
  module ORM
    module DelayedPersistence
      module DelayedPersistenceTestReceiver
        attr_reader :create_or_update_called, :do_destroy_called

        def initialize; @create_or_update_called = @do_destroy_called = 0; end

        private
        def create_or_update; @create_or_update_called += 1; end
        def do_destroy; @do_destroy_called += 1; end
      end

      class DelayedPersistenceTest
        include DelayedPersistenceTestReceiver
        include DelayedPersistence
      end


      describe DelayedPersistenceTest do
        describe "#delayed_persistence" do
          it "respond to it" do
            subject.should be_respond_to :delayed_persistence
          end

          it "takes a block and executes it" do
            done = false

            subject.delayed_persistence do
              done = true
            end

            done.should be_true
          end

          CAPTURES.each do |action|
            it "passes #{action} on to super if inactive" do
              subject.send(action)
              subject.send("#{action}_called").should eq 1
            end

            it "records that it needs to call #{action} after block is executed" do
              recorded_actions = []

              subject.delayed_persistence do
                subject.send(action)
                recorded_actions = subject.send(:delayed_persistence_stack).dup
              end

              recorded_actions.should include action
            end

            it "calls #{action} once after block is executed" do
              subject.delayed_persistence do
                5.times { subject.send(action) }
              end

              subject.send("#{action}_called").should eq 1
            end
          end

          it "does not call any other actions than the one(s) called inside of the block" do
            subject.delayed_persistence do
              2.times { subject.send(:create_or_update) ; subject.send(:do_destroy) }
            end

            subject.create_or_update_called.should eq 1
            subject.do_destroy_called.should eq 1
          end
        end

        describe "#suppress_persistence" do
          it "responds to it" do
            subject.should be_respond_to :suppress_persistence
          end

          it "takes a block and executes it" do
            done = false

            subject.suppress_persistence do
              done = true
            end

            done.should be_true
          end

          CAPTURES.each do |action|
            it "suppresses call to #{action}" do
              subject.suppress_persistence do
                2.times { subject.send(action) }
              end

              subject.send("#{action}_called").should eq 0
            end
          end
        end
      end


    end
  end
end

