class CountersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_counter, only: [ :update, :destroy ]

  def index
    @current_goal = find_or_create_current_goal
    @new_counter = current_user.counters.build
    @new_counter.mode ||= "duration"
    @new_counter.start_date ||= Date.current
    @counters = current_user.counters.ordered
  end

  def create
    @new_counter = current_user.counters.build(counter_params)

    if @new_counter.save
      redirect_to counters_path, notice: "Counter created."
    else
      load_index_data
      render :index, status: :unprocessable_content
    end
  end

  def update
    if @counter.update(counter_params)
      redirect_to counters_path, notice: "Counter updated."
    else
      load_index_data
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    @counter.destroy!
    redirect_to counters_path, notice: "Counter deleted."
  end

  private

  def set_counter
    @counter = current_user.counters.find(params[:id])
  end

  def counter_params
    params.require(:counter).permit(
      :title, :start_date, :end_date, :direction, :mode,
      :duration_value, :duration_unit, units: []
    )
  end

  def find_or_create_current_goal
    current_user.counters.find_or_create_by(tag: Counter::CURRENT_GOAL_TAG) do |counter|
      counter.title = "Current Goal"
      counter.mode = "duration"
      counter.start_date = Date.current
      counter.duration_value = 1
      counter.duration_unit = "months"
      counter.end_date = Date.current + 1.month
      counter.direction = "descending"
      counter.units = [ "days" ]
    end
  end

  def load_index_data
    @new_counter = current_user.counters.build
    @current_goal = if @counter.present? && @counter.current_goal?
      @counter
    else
      current_user.counters.find_or_initialize_by(tag: Counter::CURRENT_GOAL_TAG)
    end
    @counters = current_user.counters.ordered
  end
end
