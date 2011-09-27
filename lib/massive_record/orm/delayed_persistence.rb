module MassiveRecord
  module ORM
    module DelayedPersistence
      extend ActiveSupport::Concern

      CAPTURES = %w(create_or_update do_destroy)

      module InstanceMethods

        def delayed_persistence
          @inside_of_manipulated_persistence = true
          yield
        ensure
          @inside_of_manipulated_persistence = false
          commit_recored_delayed_persistence_actions
        end


        def suppress_persistence
          @inside_of_manipulated_persistence = true
          yield
        ensure
          @inside_of_manipulated_persistence = false
          delayed_persistence_stack.clear
        end

        private



        CAPTURES.each do |action|
          define_method action do
            manipulate_persistence_action? ? record_action(action) : super()
          end
        end




        def record_action(action)
          delayed_persistence_stack.push(action.to_s)
          true
        end

        def delayed_persistence_stack
          @delayed_persistence_stack ||= []
        end




        def manipulate_persistence_action?
          !!@inside_of_manipulated_persistence
        end

        def commit_recored_delayed_persistence_actions
          delayed_persistence_stack.uniq.each { |action| send(action) }
          delayed_persistence_stack.clear
        end
      end
    end
  end
end
