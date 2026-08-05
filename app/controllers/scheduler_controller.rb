class SchedulerController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date

  def index
    @templates = current_user.task_templates.ordered
    @ringtones = current_user.ringtones.ordered
    @new_template = current_user.task_templates.build
    @new_ringtone = current_user.ringtones.build
    @view = params[:view].presence || "day"

    case @view
    when "week" then load_week
    when "month" then load_month
    when "stats" then load_stats
    else load_day
    end
  end

  # JSON payload for the global alarm checker (runs on every page).
  # The browser passes its own local date so the right day's tasks are picked,
  # and wall-clock components let the browser build exact epochs in its zone.
  def alarms
    today = params[:date].presence&.to_date || Date.current
    render json: schedules_for(today).map { |task|
      start = task.start_time
      {
        id: task.id,
        title: task.title,
        tag: task.tag,
        ringtone: task.ringtone&.audio_url,
        alarm_minutes_before: task.alarm_minutes_before,
        start: {
          year: today.year,
          month: today.month,
          day: today.day,
          hour: start.hour,
          min: start.min
        }
      }
    }
  end

  private

  def set_date
    @date = params[:date].presence&.to_date || Date.current
  end

  def load_day
    @schedules = schedules_for(@date)
  end

  def load_week
    @week_start = @date.beginning_of_week
    @days = (0..6).map { |i| @week_start + i }
    @week_schedules = @days.index_with { |d| schedules_for(d) }
  end

  def load_month
    @month_start = @date.beginning_of_month.beginning_of_week
    @month_end = @date.end_of_month.end_of_week
    @month_schedules = (@month_start..@month_end).to_a.index_with { |d| schedules_for(d) }
  end

  def load_stats
    @from = params[:from].presence&.to_date || 30.days.ago.to_date
    @to = params[:to].presence&.to_date || Date.current

    logs = current_user.time_logs.for_range(@from, @to).where.not(ended_at: nil)
    @by_day = logs.group_by { |l| l.started_at.to_date }
                  .transform_values { |day_logs| day_logs.sum(&:duration_minutes) }
    @by_tag = logs.group_by { |l| l.task&.tag }
                  .transform_values { |tl| tl.sum(&:duration_minutes) }
    @by_template = logs.group_by { |l| l.task_template }
                       .transform_values { |tl| tl.sum(&:duration_minutes) }
    @total_minutes = logs.sum(&:duration_minutes)
  end

  def schedules_for(date)
    current_user.task_templates
                .select { |t| t.occurs_on?(date) }
                .flat_map { |t| t.tasks.ordered }
                .sort_by(&:start_time)
  end
end
