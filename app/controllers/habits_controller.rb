class HabitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: %i[ show edit update destroy ]

  # GET /habits or /habits.json
  def index
    # @habits = Habit.all
    @habits = current_user.habits.order(position: :asc)
  end

  # GET /habits/1 or /habits/1.json
  def show
  end

  # GET /habits/new
  def new
    #@habit = Habit.new
    @habit = current_user.habits.build
  end

  # GET /habits/1/edit
  def edit
  end

  # POST /habits or /habits.json
  def create
    @habit = current_user.habits.build(habit_params)

    respond_to do |format|
      if @habit.save
        format.html { redirect_to @habit, notice: "Habit was successfully created." }
        format.json { render :show, status: :created, location: @habit }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @habit.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /habits/1 or /habits/1.json
  def update
    respond_to do |format|
      if @habit.update(habit_params)
        format.html { redirect_to @habit, notice: "Habit was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @habit }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @habit.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /habits/1 or /habits/1.json
  def destroy
    @habit.destroy!

    respond_to do |format|
      format.html { redirect_to habits_path, notice: "Habit was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def submit_ratings
    ratings = params[:ratings] || {}
    today = Date.current

    begin
      ActiveRecord::Base.transaction do
        ratings.each do |habit_id, rating|
          next if rating.blank?

          habit = current_user.habits.find_by(id: habit_id)
          next unless habit

          day_habit = current_user.day_habits.find_or_initialize_by(
            habit_id: habit.id,
            date: today
          )
          day_habit.rating = rating
          day_habit.save!
        end
      end
      redirect_to habits_path, notice: "Today's ratings saved successfully!"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to habits_path, alert: "Failed to save ratings: #{e.record.errors.full_messages.join(', ')}"
    end
  end

  def update_order
    habit_ids = params[:habit_ids] || []
    
    ActiveRecord::Base.transaction do
      habit_ids.each_with_index do |id, index|
        habit = current_user.habits.find_by(id: id)
        habit.update!(position: index + 1) if habit
      end
    end

    render json: { success: true }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_habit
      @habit = Habit.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def habit_params
      params.expect(habit: [ :title, :completed_date ])
    end
end
