class Flashcard < ApplicationRecord
  RATINGS = { again: 1, hard: 2, good: 3, easy: 4 }.freeze

  belongs_to :user
  belongs_to :flashcard_deck
  belongs_to :chinese_word
  has_many :review_logs, dependent: :destroy

  enum :state, { new: 0, learning: 1, review: 2, relearning: 3 }, scopes: false

  validates :chinese_word_id, uniqueness: { scope: :flashcard_deck_id }

  scope :due, -> { where("due_at <= ?", Time.current) }
  scope :studied, -> { where("reps > 0") }

  # Anki-style card phases
  def phase
    if state_before_type_cast == 0 || reps == 0
      :new
    elsif state_before_type_cast.in?([ 1, 3 ])
      :learning
    elsif scheduled_days < 21
      :young
    else
      :mature
    end
  end

  def review!(rating, now: Time.current)
    was_new = state_before_type_cast == 0
    card = Fsrs::Card.new(
      due_at: due_at,
      stability: stability.to_f,
      difficulty: difficulty.to_f,
      elapsed_days: elapsed_days,
      scheduled_days: scheduled_days,
      reps: reps,
      lapses: lapses,
      state: state_before_type_cast,
      last_review_date: last_review_date
    )

    result = Fsrs.review(card, rating, now: now)

    assign_attributes(
      state: result.card.state,
      due_at: result.card.due_at,
      stability: result.card.stability,
      difficulty: result.card.difficulty,
      elapsed_days: result.card.elapsed_days,
      scheduled_days: result.card.scheduled_days,
      reps: result.card.reps,
      lapses: result.card.lapses,
      last_review_date: result.card.last_review_date
    )
    self.first_review_date = result.review_date if was_new && first_review_date.nil?
    save!

    review_logs.create!(
      user: user,
      rating: rating,
      state_before: result.state_before,
      state_after: result.card.state,
      review_date: result.review_date
    )

    result
  end
end
