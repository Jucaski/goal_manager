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
    @period = %w[day week month year].include?(params[:period]) ? params[:period] : "week"

    if params[:from].present? || params[:to].present?
      @from = params[:from].presence&.to_date || Date.current
      @to = params[:to].presence&.to_date || Date.current
    else
      @from, @to = range_for_period(@period)
    end

    logs = current_user.time_logs.for_range(@from, @to).where.not(ended_at: nil)
    @total_minutes = logs.sum(&:duration_minutes)

    @by_task = logs.group_by { |l| l.task }
                   .transform_values { |tl| tl.sum(&:duration_minutes) }
                   .sort_by { |_task, minutes| -minutes }
                   .to_h
    @by_tag = logs.group_by { |l| l.task&.tag }
                  .transform_values { |tl| tl.sum(&:duration_minutes) }
                  .sort_by { |_tag, minutes| -minutes }
                  .to_h
    @sessions = logs.includes(:task).ordered.limit(50)

    @time_labels, @time_values = time_series(logs)
  end

  def range_for_period(period)
    case period
    when "day"   then [ Date.current, Date.current ]
    when "month" then [ Date.current.beginning_of_month, Date.current.end_of_month ]
    when "year"  then [ Date.current.beginning_of_year, Date.current.end_of_year ]
    else              [ Date.current.beginning_of_week, Date.current.end_of_week ]
    end
  end

  def time_series(logs)
    case @period
    when "day"
      labels = (0..23).map { |h| format("%02d:00", h) }
      values = labels.map { |label| logs.sum { |l| l.started_at.hour == label.to_i ? l.duration_minutes : 0 } }
    when "year"
      labels = Date::MONTHNAMES.compact
      values = labels.map.with_index { |_name, i| logs.sum { |l| l.started_at.month == i + 1 ? l.duration_minutes : 0 } }
    else
      labels = (@from..@to).to_a.map(&:to_s)
      by_day = logs.group_by { |l| l.started_at.to_date }.transform_values { |dl| dl.sum(&:duration_minutes) }
      values = labels.map { |date_str| by_day[Date.parse(date_str)].to_i }
    end
    [ labels, values ]
  end

  def schedules_for(date)
    current_user.task_templates
                .select { |t| t.occurs_on?(date) }
                .flat_map { |t| t.tasks.ordered }
                .sort_by(&:start_time)
  end
end
