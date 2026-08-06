module Api
  module V1
    class CountersController < BaseController
      def index
        current_goal = current_user.counters.find_by(tag: Counter::CURRENT_GOAL_TAG)
        counters = current_user.counters.where.not(tag: Counter::CURRENT_GOAL_TAG).ordered

        render json: {
          current_goal: current_goal && counter_payload(current_goal),
          counters: counters.map { |c| counter_payload(c) }
        }
      end

      private

      def counter_payload(counter)
        {
          id: counter.id,
          title: counter.title,
          tag: counter.tag,
          units: Array(counter.units).map { |unit| { unit: unit, value: counter.value_for(unit), total: counter.total_value_for(unit) } },
          direction: counter.direction
        }
      end
    end
  end
end
