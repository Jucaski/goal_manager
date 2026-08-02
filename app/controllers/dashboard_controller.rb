class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Current goal counter
    @current_goal = current_user.counters.find_by(tag: Counter::CURRENT_GOAL_TAG)

    # Timers history calendar
    @sessions = current_user.workout_sessions.order(:date)

    # Day habits table
    @dates = (9.days.ago.to_date..Date.current).to_a
    @habits = current_user.habits.order(position: :asc)
    @ratings_map = current_user.day_habits
                                .where(habit_id: @habits.ids, date: @dates)
                                .group_by(&:habit_id)
                                .transform_values { |records| records.index_by(&:date) }

    # Reading stats (current month)
    @year = Date.current.year
    @month = Date.current.month
    month_range = (Date.new(@year, @month, 1)...Date.new(@year, @month, 1).next_month)

    finished_logs = current_user.reading_logs
      .joins(:book)
      .where.not(finish_date: nil)
      .where(books: { user_id: current_user.id })
      .where(finish_date: month_range)

    @books_finished = finished_logs.count
    @pages_read = finished_logs.sum("books.total_pages")

    @monthly_plan = current_user.monthly_plans.for_year(@year).find_by(month: @month)
    @planned_books_count = @monthly_plan&.planned_books&.size.to_i
    @planned_pages = if @monthly_plan
      @monthly_plan.planned_books.includes(:book).sum { |pb| pb.book.total_pages || 0 }
    else
      0
    end

    if @planned_pages > 0
      remaining_pages = @planned_pages - @pages_read
      days_in_month = Time.days_in_month(@month, @year)
      remaining_days = days_in_month - Date.current.day
      @pages_per_day = remaining_days > 0 ? (remaining_pages.to_f / remaining_days).round(1) : 0
    else
      @pages_per_day = 0
    end

    # Flashcards summary per deck
    decks = current_user.flashcard_decks
    cards_by_deck = Flashcard.where(flashcard_deck_id: decks.ids).group_by(&:flashcard_deck_id)
    review_logs_by_deck = ReviewLog.joins(:flashcard)
      .where(flashcards: { flashcard_deck_id: decks.ids })
      .group(:flashcard_deck_id, :review_date)
      .count
      .each_with_object(Hash.new { |h, k| h[k] = {} }) do |((deck_id, date), count), acc|
        acc[deck_id][date] = count
      end

    @decks_with_summary = decks.map do |deck|
      cards = cards_by_deck.fetch(deck.id, [])
      counts = { new: 0, learning: 0, young: 0, mature: 0 }
      cards.each { |card| counts[card.phase] += 1 }

      {
        deck: deck,
        cards_count: cards.size,
        due_count: deck.due_cards.count,
        phase_counts: counts,
        review_counts_by_day: review_logs_by_deck.fetch(deck.id, {})
      }
    end
  end

  def settings
  end
end
