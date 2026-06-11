class FocusController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:complete]

  def show
    # Validate parameters passed from timer or template
    @sets = params[:sets].to_i
    @work = params[:work].to_i
    @rest = params[:rest].to_i
    @is_running = params[:is_running] == "true"
    @template_id = params[:template_id]   # optional

    if @sets <= 0 || @work <= 0 || @rest <= 0
      redirect_to root_path, alert: "Invalid workout parameters"
    end
  end

  def complete
  session[:completed_workout] = {
    sets: params[:sets],
    work: params[:work],
    rest: params[:rest],
    is_running: params[:is_running],
    template_id: params[:template_id].presence,   # <-- this will store nil if blank
    date: Date.current.to_s
  }
  redirect_to new_workout_session_path
end
end
