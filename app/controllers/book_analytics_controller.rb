class BookAnalyticsController < ApplicationController
  before_action :authenticate_user!

  def show
    @year = (params[:year] || Date.current.year).to_i
    @yearly_goal = current_user.yearly_goals.find_by(year: @year)

    finished_logs = current_user.reading_logs
      .joins(:book)
      .where.not(finish_date: nil)
      .where(books: { user_id: current_user.id })
      .where("finish_date >= ? AND finish_date <= ?", Date.new(@year, 1, 1), Date.new(@year, 12, 31))

    @books_finished = finished_logs.count
    @total_pages_read = finished_logs.joins(:book).sum("books.total_pages")
    @avg_days_per_book = if @books_finished > 0
      total_days = finished_logs.sum("finish_date - start_date")
      (total_days.to_f / @books_finished).round(1)
    else
      0
    end

    @monthly_data = (1..12).map do |m|
      logs = finished_logs.select { |l| l.finish_date.month == m }
      count = logs.size
      pages = logs.sum { |l| l.book.total_pages || 0 }
      books = logs.map { |l| l.book }
      { month: m, count: count, pages: pages, books: books }
    end

    finished_by_book = finished_logs.includes(:book).to_a

    @genre_data = finished_by_book
      .group_by { |log| log.book.genre.presence || "Uncategorized" }
      .transform_values { |logs| { count: logs.size, books: logs.map(&:book) } }
      .sort_by { |_, data| -data[:count] }
      .to_h
  end
end
