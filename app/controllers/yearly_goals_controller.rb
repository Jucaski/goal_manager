class YearlyGoalsController < ApplicationController
  before_action :authenticate_user!

  def create
    @goal = current_user.yearly_goals.build(goal_params)
    if @goal.save
      redirect_to book_planner_path, notice: "Yearly goal set."
    else
      redirect_to book_planner_path, alert: @goal.errors.full_messages.join(", ")
    end
  end

  def update
    @goal = current_user.yearly_goals.find(params[:id])
    if @goal.update(goal_params)
      redirect_to book_planner_path, notice: "Yearly goal updated."
    else
      redirect_to book_planner_path, alert: @goal.errors.full_messages.join(", ")
    end
  end

  private

  def goal_params
    params.require(:yearly_goal).permit(:year, :target_books)
  end
end
