class BookPlannerController < ApplicationController
  before_action :authenticate_user!

  def show
    @year = (params[:year] || Date.current.year).to_i
    @month = (params[:month] || Date.current.month).to_i

    @yearly_goal = current_user.yearly_goals.find_or_initialize_by(year: @year)
    @books = current_user.books.order(:title)
    @monthly_plan = current_user.monthly_plans.find_or_initialize_by(year: @year, month: @month)
    @available_books = if @monthly_plan.persisted?
      @books.where.not(id: @monthly_plan.planned_books.select(:book_id))
    else
      @books
    end
    @planned_books = if @monthly_plan.persisted?
      @monthly_plan.planned_books.ordered.includes(:book)
    else
      []
    end

    @reading_logs = current_user.reading_logs.includes(:book).index_by(&:book_id)

    @weeks = build_weeks(@planned_books)
  end

  private

  def build_weeks(planned_books)
    return [] if planned_books.empty?
    books_per_week = (planned_books.size / 4.0).ceil
    planned_books.each_slice(books_per_week).with_index.map do |slice, i|
      { week: i + 1, planned_books: slice }
    end
  end
end
