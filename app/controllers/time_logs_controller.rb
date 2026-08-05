class TimeLogsController < ApplicationController
  before_action :authenticate_user!

  def start
    @task = current_user.tasks.find(params[:task_id])
    @date = params[:date].presence&.to_date || Date.current

    @log = @task.active_time_log_for(@date)

    if @log.nil?
      @log = current_user.time_logs.create!(
        task: @task,
        started_at: Time.zone.now
      )
    end

    redirect_to scheduler_path(date: @date), notice: "Started #{@task.title}."
  end

  def stop
    @log = current_user.time_logs.find(params[:id])
    @log.stop!
    @date = @log.started_at.to_date

    redirect_to scheduler_path(date: @date), notice: "Stopped. #{@log.duration_minutes} minutes logged."
  end
end
