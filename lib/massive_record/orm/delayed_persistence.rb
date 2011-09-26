module MassiveRecord
  module ORM
    module DelayedPersistence
      extend ActiveSupport::Concern

      CAPTURES = %w(create update do_destroy)

      module InstanceMethods
        def delayed_persistence
          @inside_of_delayed_persistence = true
          yield
        ensure
          @inside_of_delayed_persistence = false
          commit_recored_delayed_persistence_actions
        end


        private



        def create
          delay_persistence_action? ? record_action(:create) : super
        end
        
        def update(attrs = [])
          delay_persistence_action? ? record_action(:update) : super
        end

        def do_destroy
          delay_persistence_action? ? record_action(:do_destroy) : super
        end




        def record_action(action)
          delayed_persistence_stack.push(action.to_s)
          true
        end

        def delayed_persistence_stack
          @delayed_persistence_stack ||= []
        end




        def delay_persistence_action?
          !!@inside_of_delayed_persistence
        end

        def commit_recored_delayed_persistence_actions
          delayed_persistence_stack.uniq.each { |action| send(action) }
        end
      end
    end
  end
end
