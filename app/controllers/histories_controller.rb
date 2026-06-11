class HistoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @sessions_by_date = current_user.workout_sessions.group_by(&:date)
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
  end
end
