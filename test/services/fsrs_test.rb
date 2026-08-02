require "test_helper"

class FsrsTest < ActiveSupport::TestCase
  def new_card
    Fsrs::Card.new(
      due_at: Time.new(2022, 12, 29, 12, 0, 0),
      stability: 0,
      difficulty: 0,
      elapsed_days: 0,
      scheduled_days: 0,
      reps: 0,
      lapses: 0,
      state: Fsrs::STATE_NEW,
      last_review_date: nil
    )
  end

  def review(card, rating, days_later)
    Fsrs.review(card, rating, now: Time.new(2022, 12, 29, 12, 0, 0) + days_later.days)
  end

  test "new card with Good graduates to Review with a day interval" do
    now = Time.new(2022, 12, 29, 12, 0, 0)
    result = Fsrs.review(new_card, Fsrs::RATING_GOOD, now: now)
    assert_equal Fsrs::STATE_REVIEW, result.card.state
    assert_equal 2, result.card.scheduled_days
    assert_equal (now + 2.days).beginning_of_day, result.card.due_at
    assert_equal 2.4, result.card.stability.round(1)
    assert_equal 4.93, result.card.difficulty.round(2)
    assert_equal Fsrs::STATE_NEW, result.state_before
  end

  test "a sequence of Good reviews produces increasing intervals" do
    card = new_card
    intervals = []

    [ Fsrs::RATING_GOOD, Fsrs::RATING_GOOD, Fsrs::RATING_GOOD, Fsrs::RATING_GOOD ].each_with_index do |rating, i|
      result = review(card, rating, i)
      card = result.card
      intervals << result.card.scheduled_days
    end

    assert_equal [ 2, 5, 7, 9 ], intervals
  end

  test "Again on a Review card sends it to Relearning and increments lapses" do
    card = new_card
    3.times { |i| card = review(card, Fsrs::RATING_GOOD, i).card }
    assert_equal Fsrs::STATE_REVIEW, card.state

    result = review(card, Fsrs::RATING_AGAIN, 3)
    assert_equal Fsrs::STATE_RELEARNING, result.card.state
    assert_equal 1, result.card.lapses
    assert_equal 0, result.card.scheduled_days
    assert_equal Time.new(2022, 12, 29, 12, 0, 0) + 3.days + 10.seconds, result.card.due_at
  end

  test "Again and Hard learning steps bring cards back within the session" do
    now = Time.new(2022, 12, 29, 12, 0, 0)

    again = Fsrs.review(new_card, Fsrs::RATING_AGAIN, now: now)
    assert_equal now + 10.seconds, again.card.due_at
    assert_equal Fsrs::STATE_LEARNING, again.card.state

    hard = Fsrs.review(new_card, Fsrs::RATING_HARD, now: now)
    assert_equal now + 30.seconds, hard.card.due_at
  end

  test "invalid rating is rejected" do
    assert_raises(ArgumentError) { review(new_card, 5, 0) }
  end
end
