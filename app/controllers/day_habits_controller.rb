class DayHabitsController < ApplicationController
  before_action :set_day_habit, only: %i[ show edit update destroy ]

  # GET /day_habits or /day_habits.json
  def index
    flash[:success] = "If you see this, the gem is working!"
redirect_to habits_path
    # 1. Define the last 30 days (this fixes the 'nil' error)
    @dates = (9.days.ago.to_date..Date.current).to_a
    
    # 2. Load habits ordered by position
    @habits = current_user.habits.order(position: :asc)
    
    # 3. Optimization: Fetch all ratings for these habits in one query
    # We group by habit_id, then index by date for fast lookup in the view
    @ratings_map = current_user.day_habits
                                .where(habit_id: @habits.ids, date: @dates)
                                .group_by(&:habit_id)
                                .transform_values { |records| records.index_by(&:date) }
  end

  # GET /day_habits/1 or /day_habits/1.json
  def show
  end

  # GET /day_habits/new
  def new
    #@day_habit = DayHabit.new
    @day_habit = current_user.day_habits.build
  end

  # GET /day_habits/1/edit
  def edit
  end

  # POST /day_habits or /day_habits.json
  def create
    #@day_habit = DayHabit.new(day_habit_params)
    @day_habit = current_user.day_habits.build(day_habit_params)

    respond_to do |format|
      if @day_habit.save
        format.html { redirect_to @day_habit, notice: "Day habit was successfully created." }
        format.json { render :show, status: :created, location: @day_habit }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @day_habit.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /day_habits/1 or /day_habits/1.json
  def update
    respond_to do |format|
      if @day_habit.update(day_habit_params)
        format.html { redirect_to @day_habit, notice: "Day habit was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @day_habit }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @day_habit.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /day_habits/1 or /day_habits/1.json
  def destroy
    @day_habit.destroy!

    respond_to do |format|
      format.html { redirect_to day_habits_path, notice: "Day habit was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end
 def history
    @habits = current_user.habits.order(position: :asc)

    @dates = (29.days.ago.to_date..Date.current).to_a

    @day_habits_by_habit = current_user.day_habits
      .where(date: @dates)
      .group_by(&:habit_id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_day_habit
      @day_habit = DayHabit.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def day_habit_params
      params.expect(day_habit: [ :habit_id, :date, :rating ])
    end
end
