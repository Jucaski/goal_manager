class ReadingLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_log, only: [:update, :destroy]

  def create
    @book = current_user.books.find(params[:reading_log][:book_id])
    @log = current_user.reading_logs.build(log_params.merge(book: @book))
    parse_dates
    if @log.save
      redirect_to book_planner_path, notice: "Reading log saved."
    else
      redirect_to book_planner_path, alert: @log.errors.full_messages.join(", ")
    end
  end

  def update
    @log.assign_attributes(log_params)
    parse_dates
    if @log.save
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

  def parse_dates
    %i[start_date finish_date].each do |field|
      raw = params[:reading_log][field]
      next if raw.blank?
      parts = raw.to_s.split("/")
      if parts.size == 3
        @log[field] = Date.new(parts[2].to_i, parts[1].to_i, parts[0].to_i) rescue nil
      end
    end
  end
end
