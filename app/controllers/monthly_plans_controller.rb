class MonthlyPlansController < ApplicationController
  before_action :authenticate_user!

  def show
    @plan = current_user.monthly_plans.find(params[:id])
    @planned_books = @plan.planned_books.ordered.includes(:book)
  end

  def create
    @plan = current_user.monthly_plans.find_or_initialize_by(plan_params)
    if @plan.persisted? || @plan.save
      redirect_to book_planner_path(year: @plan.year, month: @plan.month)
    else
      redirect_to book_planner_path, alert: @plan.errors.full_messages.join(", ")
    end
  end

  def update
    @plan = current_user.monthly_plans.find(params[:id])
    if @plan.update(plan_params)
      redirect_to book_planner_path(year: @plan.year, month: @plan.month)
    else
      redirect_to book_planner_path, alert: @plan.errors.full_messages.join(", ")
    end
  end

  private

  def plan_params
    params.require(:monthly_plan).permit(:year, :month)
  end
end
