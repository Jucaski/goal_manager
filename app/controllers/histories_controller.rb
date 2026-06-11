class HistoriesController < ApplicationController
  before_action :authenticate_user!

  def index
  @sessions = current_user.workout_sessions.order(:date)
  @date = params[:date] ? Date.parse(params[:date]) : Date.current
end
end
