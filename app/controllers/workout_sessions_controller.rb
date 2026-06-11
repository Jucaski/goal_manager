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

  def session_params
  params.require(:workout_session).permit(
    :sets, :work_duration, :rest_duration, :is_running,
    :note, :distance, :calories, :max_pace, :workout_template_id
  ).tap do |p|
    p[:workout_template_id] = nil if p[:workout_template_id].to_i == 0
  end.merge(date: Date.current)
end
end
