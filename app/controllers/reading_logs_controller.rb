class ReadingLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_log, only: [:update, :destroy]

  def create
    @book = current_user.books.find(params[:reading_log][:book_id])
    @log = current_user.reading_logs.build(log_params.merge(book: @book))
    if @log.save
      redirect_to book_planner_path, notice: "Reading log saved."
    else
      redirect_to book_planner_path, alert: @log.errors.full_messages.join(", ")
    end
  end

  def update
    if @log.update(log_params)
      redirect_to book_planner_path, notice: "Reading log updated."
    else
      redirect_to book_planner_path, alert: @log.errors.full_messages.join(", ")
    end
  end

  def destroy
    @log.destroy
    redirect_to book_planner_path, notice: "Reading log removed."
  end

  private

  def set_log
    @log = current_user.reading_logs.find(params[:id])
  end

  def log_params
    params.require(:reading_log).permit(:start_date, :finish_date, :rating, :notes)
  end
end
