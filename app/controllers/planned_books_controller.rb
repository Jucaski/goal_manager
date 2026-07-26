class PlannedBooksController < ApplicationController
  before_action :authenticate_user!

  def create
    @plan = current_user.monthly_plans.find(params[:monthly_plan_id])
    @book = current_user.books.find(params[:book_id])
    max_position = @plan.planned_books.maximum(:position) || -1
    @planned = @plan.planned_books.build(
      book: @book,
      user: current_user,
      position: max_position + 1
    )
    if @planned.save
      redirect_to book_planner_path(year: @plan.year, month: @plan.month), notice: "Book added to plan."
    else
      redirect_to book_planner_path(year: @plan.year, month: @plan.month), alert: @planned.errors.full_messages.join(", ")
    end
  end

  def destroy
    @planned = current_user.planned_books.find(params[:id])
    plan = @planned.monthly_plan
    @planned.destroy
    redirect_to book_planner_path(year: plan.year, month: plan.month), notice: "Book removed from plan."
  end

  def reorder
    plan = current_user.monthly_plans.find(params[:monthly_plan_id])
    params[:positions].each do |id, position|
      plan.planned_books.find(id).update!(position: position)
    end
    redirect_to book_planner_path(year: plan.year, month: plan.month), notice: "Order updated."
  end

  def move_up
    @planned = current_user.planned_books.find(params[:id])
    @above = @planned.monthly_plan.planned_books.where("position < ?", @planned.position).order(position: :desc).first
    if @above
      @above.update(position: @planned.position)
      @planned.update(position: @planned.position - 1)
    end
    redirect_to book_planner_path(year: @planned.monthly_plan.year, month: @planned.monthly_plan.month)
  end

  def move_down
    @planned = current_user.planned_books.find(params[:id])
    @below = @planned.monthly_plan.planned_books.where("position > ?", @planned.position).order(:position).first
    if @below
      @below.update(position: @planned.position)
      @planned.update(position: @planned.position + 1)
    end
    redirect_to book_planner_path(year: @planned.monthly_plan.year, month: @planned.monthly_plan.month)
  end

  private

  def planned_book_params
    params.require(:planned_book).permit(:book_id)
  end
end
