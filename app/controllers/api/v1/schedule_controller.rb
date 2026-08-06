module Api
  module V1
    class ScheduleController < BaseController
      def today
        date = params[:date].presence&.to_date || Date.current
        tasks = tasks_for(date)
        remaining = tasks.reject { |task| task.completed_on?(date) }

        now = Time.current
        render json: {
          date: date.iso8601,
          tasks: remaining.map { |task| task_payload(task, date) },
          next_task: next_task(remaining, date, now)
        }
      end

      # Marks a task as completed for the given date so it disappears from today's list.
      def complete
        task = current_user.tasks.find(params[:id])
        date = params[:date].presence&.to_date || Date.current
        task.task_completions.find_or_create_by!(date: date, user_id: current_user.id)

        render json: task_payload(task, date), status: :ok
      end

      # Un-marks a task for the given date (restores it to today's list).
      def uncomplete
        task = current_user.tasks.find(params[:id])
        date = params[:date].presence&.to_date || Date.current
        task.task_completions.find_by(date: date)&.destroy

        render json: task_payload(task, date), status: :ok
      end

      private

      def tasks_for(date)
        current_user.task_templates
                    .select { |t| t.occurs_on?(date) }
                    .flat_map { |t| t.tasks.ordered }
                    .sort_by(&:start_time)
      end

      def task_payload(task, date)
        {
          id: task.id,
          title: task.title,
          tag: task.tag,
          start_time: task.start_time.strftime("%H:%M"),
          end_time: task.end_datetime(date).strftime("%H:%M"),
          duration_minutes: task.duration_minutes,
          alarm_minutes_before: task.alarm_minutes_before,
          ringtone_name: task.ringtone&.name,
          ringtone_audio_url: task.ringtone&.audio_url,
          completed: task.completed_on?(date)
        }
      end

      def next_task(tasks, date, now)
        upcoming = tasks.find { |task| task.end_datetime(date) > now }
        upcoming && task_payload(upcoming, date)
      end
    end
  end
end
