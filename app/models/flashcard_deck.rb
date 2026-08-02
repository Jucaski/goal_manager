class FlashcardDeck < ApplicationRecord
  KINDS = %w[configurable writing].freeze

  belongs_to :user
  has_many :flashcards, dependent: :destroy

  validates :name, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :daily_goal, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_nil: true
  validates :daily_review_goal, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_nil: true
  validate :writing_deck_fields_not_editable

  def writing?
    kind == "writing"
  end

  def configurable?
    kind == "configurable"
  end

  def due_cards
    flashcards.where.not(state: 0).where("due_at <= ?", Time.current)
  end

  # Study order:
  #  1. Words in progress (Again/Hard) — always come back until you rate Good/Easy.
  #  2. Due review words from previous days (more tries first).
  #  3. New words (up to the daily new goal).
  #  4. Any in-progress word not yet due, so the session never ends with pending ones.
  def next_card
    return pending_learning_card if pending_learning_card
    return nil if study_remaining_today.zero?

    due_review_card || next_new_card || next_pending_learning
  end

  # Cards you're still struggling with (Again/Hard, in learning/relearning) that are due.
  def pending_learning_card
    flashcards.where(state: [ 1, 3 ])
              .where("due_at <= ?", Time.current)
              .order(:due_at, :id)
              .first
  end

  def due_review_card
    # FSRS controls when each card is due; among due review cards, the ones that
    # took more tries (higher reps) get priority. Answering Good/Easy on sight
    # pushes a card far out via FSRS, so it naturally drops out of the queue.
    flashcards.where(state: 2)
              .where("due_at <= ?", Time.current)
              .order(Arel.sql("reps DESC"), :due_at, :id)
              .first
  end

  def next_new_card
    return nil if daily_goal.to_i <= 0
    return nil if new_cards_today >= daily_goal

    flashcards.where(state: 0).order(:id).first
  end

  # Fallback: bring back the in-progress word that's due soonest, even if not due yet.
  def next_pending_learning
    flashcards.where(state: [ 1, 3 ]).order(:due_at, :id).first
  end

  def new_cards_today
    flashcards.where(first_review_date: Date.current).count
  end

  def new_cards_remaining_today
    [ daily_goal.to_i - new_cards_today, 0 ].max
  end

  # Distinct words studied today (new words + reviews). Capped by the daily review goal.
  def words_studied_today
    ReviewLog.joins(:flashcard)
             .where(flashcards: { flashcard_deck_id: id })
             .where(review_date: Date.current)
             .distinct
             .count(:flashcard_id)
  end

  def study_remaining_today
    [ daily_review_goal.to_i - words_studied_today, 0 ].max
  end

  def generate_cards!
    created = 0
    cards_source.find_each do |word|
      next if flashcards.exists?(chinese_word_id: word.id)

      flashcards.create!(user: user, chinese_word: word)
      created += 1
    end
    created
  end

  def word_count
    cards_source.count
  end

  def studied_count
    flashcards.studied.count
  end

  def words_by_level
    flashcards.joins(:chinese_word).group("chinese_words.level").order("chinese_words.level").count
  end

  def phase_counts
    counts = { new: 0, learning: 0, young: 0, mature: 0 }
    flashcards.find_each { |card| counts[card.phase] += 1 }
    counts
  end

  def review_counts_by_day
    ReviewLog.joins(:flashcard)
             .where(flashcards: { flashcard_deck_id: id })
             .group(:review_date)
             .count
  end

  def cards_source
    scope = ChineseWord.all
    scope = scope.where(level: levels) if levels.present?
    scope
  end

  private

  def writing_deck_fields_not_editable
    return unless kind == "writing"
    self.front_fields = []
    self.back_fields = []
  end
end
