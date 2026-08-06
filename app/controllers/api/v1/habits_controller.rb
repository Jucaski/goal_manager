module Api
  module V1
    class HabitsController < BaseController
      def today
        date = params[:date].presence&.to_date || Date.current
        habits = current_user.habits.order(:position)
        ratings = current_user.day_habits.where(date: date).index_by(&:habit_id)

        render json: {
          date: date.iso8601,
          habits: habits.map { |habit| habit_payload(habit, ratings[habit.id]) }
        }
      end

      # rating: an integer 0-10. 0 clears the rating for the day, 1-10 sets it.
      def update_rating
        habit = current_user.habits.find(params[:id])
        date = params[:date].presence&.to_date || Date.current
        rating = params[:rating]

        if rating.blank? || !rating.to_i.between?(0, 10)
          return render json: { error: "rating must be an integer between 0 and 10" }, status: :unprocessable_content
        end

        if rating.to_i.zero?
          current_user.day_habits.find_by(habit: habit, date: date)&.destroy
          return render json: habit_payload(habit, nil), status: :ok
        end

        day_habit = current_user.day_habits.find_or_initialize_by(habit_id: habit.id, date: date)
        day_habit.rating = rating.to_i
        day_habit.save!

        render json: habit_payload(habit, day_habit), status: :ok
      end

      private

      def habit_payload(habit, day_habit)
        {
          id: habit.id,
          title: habit.title,
          rating: day_habit&.rating
        }
      end
    end
  end
end
