class WorkoutSessionsController < ApplicationController
  before_action :authenticate_user!
  def new
    @session_data = session[:completed_workout]
    redirect_to root_path, alert: "No workout to log" unless @session_data
    @workout_session = WorkoutSession.new
  end

  def create
    @workout_session = current_user.workout_sessions.build(session_params)
    @workout_session.date = Date.current
    if @workout_session.save
      log_run_time! if @workout_session.is_running
      session.delete(:completed_workout)
      redirect_to history_path, notice: "Workout logged!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @sessions = current_user.workout_sessions.order(date: :desc)
  end

  def show
    @session = current_user.workout_sessions.find(params[:id])
  end

  private

  # Running workouts also count toward the "Run" scheduled task so they show
  # up in the schedule stats graphs.
  def log_run_time!
    task = current_user.find_or_create_run_task
    duration = @workout_session.total_seconds
    return if duration <= 0

    current_user.time_logs.create!(
      task: task,
      started_at: Time.current - duration.seconds,
      ended_at: Time.current
    )
  end

  def session_params
  params.require(:workout_session).permit(
    :sets, :work_duration, :rest_duration, :is_running,
    :note, :distance, :calories, :max_pace, :workout_template_id
  ).tap do |p|
    p[:workout_template_id] = nil if p[:workout_template_id].to_i == 0
  end.merge(date: Date.current)
end
end
