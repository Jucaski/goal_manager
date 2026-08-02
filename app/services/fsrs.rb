module Fsrs
  REQUEST_RETENTION = 0.9
  MAXIMUM_INTERVAL = 36500
  W = [ 0.4, 0.6, 2.4, 5.8, 4.93, 0.94, 0.86, 0.01, 1.49, 0.14, 0.94, 2.18, 0.05, 0.34, 1.26, 0.29, 2.61 ].freeze

  RATING_AGAIN = 1
  RATING_HARD = 2
  RATING_GOOD = 3
  RATING_EASY = 4

  STATE_NEW = 0
  STATE_LEARNING = 1
  STATE_REVIEW = 2
  STATE_RELEARNING = 3

  RATINGS = { again: RATING_AGAIN, hard: RATING_HARD, good: RATING_GOOD, easy: RATING_EASY }.freeze

  # In-session learning steps: how soon a card rated Again/Hard comes back
  # while you're still studying. Short so they reliably interleave with new words.
  LEARNING_STEP_AGAIN = 10.seconds
  LEARNING_STEP_HARD = 30.seconds
  LEARNING_STEP_GOOD = 3.minutes

  Card = Struct.new(
    :due_at, :stability, :difficulty, :elapsed_days,
    :scheduled_days, :reps, :lapses, :state, :last_review_date,
    keyword_init: true
  )

  Result = Struct.new(:card, :rating, :state_before, :review_date, keyword_init: true)

  def self.review(card, rating, now: Time.current)
    raise ArgumentError, "rating must be 1..4" unless (1..4).cover?(rating)

    state_before = card.state
    card.elapsed_days = if card.state == STATE_NEW
      0
    else
      [ (now.to_date - (card.last_review_date || now).to_date).to_i, 0 ].max
    end
    card.last_review_date = now
    card.reps += 1

    s = { again: card.dup, hard: card.dup, good: card.dup, easy: card.dup }
    update_states(s, card.state)

    case card.state
    when STATE_NEW
      init_ds(s)
      s[:again].due_at = now + LEARNING_STEP_AGAIN
      s[:hard].due_at = now + LEARNING_STEP_HARD
      s[:good].scheduled_days = next_interval(s[:good].stability)
      s[:good].due_at = due_at_for(s[:good].scheduled_days, now)
      s[:easy].scheduled_days = next_interval(s[:easy].stability)
      s[:easy].due_at = due_at_for(s[:easy].scheduled_days, now)
    when STATE_LEARNING, STATE_RELEARNING
      good_interval = next_interval(s[:good].stability)
      easy_interval = [ next_interval(s[:easy].stability), good_interval + 1 ].max
      schedule(s, 0, good_interval, easy_interval)
      assign_due_times!(s, now)
    when STATE_REVIEW
      interval = card.elapsed_days
      last_d = card.difficulty
      last_s = card.stability
      retrievability = (1 + interval / (9.0 * last_s))**-1
      next_ds(s, last_d, last_s, retrievability)
      hard_interval = next_interval(s[:hard].stability)
      good_interval = next_interval(s[:good].stability)
      hard_interval = [ hard_interval, good_interval ].min
      good_interval = [ good_interval, hard_interval + 1 ].max
      easy_interval = [ next_interval(s[:easy].stability), good_interval + 1 ].max
      schedule(s, hard_interval, good_interval, easy_interval)
      assign_due_times!(s, now)
    end

    chosen = { RATING_AGAIN => :again, RATING_HARD => :hard, RATING_GOOD => :good, RATING_EASY => :easy }[rating]
    next_card = s[chosen]

    Result.new(
      card: next_card,
      rating: rating,
      state_before: state_before,
      review_date: now.to_date
    )
  end

  def self.assign_due_times!(s, now)
    s[:again].due_at = now + LEARNING_STEP_AGAIN
    s[:hard].due_at = if s[:hard].scheduled_days > 0
      due_at_for(s[:hard].scheduled_days, now)
    else
      now + LEARNING_STEP_HARD
    end
    s[:good].due_at = due_at_for(s[:good].scheduled_days, now)
    s[:easy].due_at = due_at_for(s[:easy].scheduled_days, now)
  end

  def self.due_at_for(scheduled_days, now)
    return now + LEARNING_STEP_GOOD if scheduled_days <= 0

    (now + scheduled_days.days).beginning_of_day
  end

  def self.update_states(s, state)
    case state
    when STATE_NEW
      s[:again].state = STATE_LEARNING
      s[:hard].state = STATE_LEARNING
      s[:good].state = STATE_REVIEW
      s[:easy].state = STATE_REVIEW
    when STATE_LEARNING, STATE_RELEARNING
      s[:again].state = state
      s[:hard].state = state
      s[:good].state = STATE_REVIEW
      s[:easy].state = STATE_REVIEW
    when STATE_REVIEW
      s[:again].state = STATE_RELEARNING
      %i[hard good easy].each { |key| s[key].state = STATE_REVIEW }
      s[:again].lapses += 1
    end
  end

  def self.schedule(s, hard_interval, good_interval, easy_interval)
    s[:again].scheduled_days = 0
    s[:hard].scheduled_days = hard_interval
    s[:good].scheduled_days = good_interval
    s[:easy].scheduled_days = easy_interval
  end

  def self.init_ds(s)
    %i[again hard good easy].each do |key|
      r = RATINGS.fetch(key)
      s[key].difficulty = init_difficulty(r)
      s[key].stability = init_stability(r)
    end
  end

  def self.next_ds(s, last_d, last_s, retrievability)
    %i[again hard good easy].each do |key|
      r = RATINGS.fetch(key)
      s[key].difficulty = next_difficulty(last_d, r)
      s[key].stability = if r == RATING_AGAIN
        next_forget_stability(last_d, last_s, retrievability)
      else
        next_recall_stability(last_d, last_s, retrievability, r)
      end
    end
  end

  def self.init_stability(r)
    [ W[r - 1], 0.1 ].max
  end

  def self.init_difficulty(r)
    [ [ W[4] - W[5] * (r - 3), 1 ].max, 10 ].min
  end

  def self.next_interval(s)
    interval = s * 9 * (1.0 / REQUEST_RETENTION - 1)
    [ [ interval.round, 1 ].max, MAXIMUM_INTERVAL ].min
  end

  def self.next_difficulty(d, r)
    [ [ mean_reversion(W[4], d - W[6] * (r - 3)), 1 ].max, 10 ].min
  end

  def self.mean_reversion(init, current)
    W[7] * init + (1 - W[7]) * current
  end

  def self.next_recall_stability(d, s, r, rating)
    hard_penalty = rating == RATING_HARD ? W[15] : 1
    easy_bonus = rating == RATING_EASY ? W[16] : 1
    s * (1 + Math.exp(W[8]) * (11 - d) * (s**-W[9]) * (Math.exp((1 - r) * W[10]) - 1) * hard_penalty * easy_bonus)
  end

  def self.next_forget_stability(d, s, r)
    W[11] * (d**-W[12]) * ((s + 1)**W[13] - 1) * Math.exp((1 - r) * W[14])
  end
end
