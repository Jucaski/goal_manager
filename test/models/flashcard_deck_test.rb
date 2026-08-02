require "test_helper"

class FlashcardDeckTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @user = users(:one)
    %w[爱 八 爸 杯].each do |word|
      @user.chinese_words.create!(word: word, pinyin: "x", part_of_speech: "n", translation: "t", level: 1)
    end
    @deck = @user.flashcard_decks.create!(
      name: "HSK", kind: "configurable",
      front_fields: [ "word" ], back_fields: [ "translation" ],
      levels: [ 1 ], daily_goal: 2
    )
    @deck.generate_cards!
  end

  test "due_cards excludes brand new cards" do
    assert_equal 0, @deck.due_cards.count
    assert_equal 4, @deck.flashcards.count
  end

  test "daily goal stops new cards once reached" do
    2.times do
      card = @deck.next_card
      assert_not_nil card
      card.review!(3)
    end

    assert_equal 2, @deck.new_cards_today
    assert_nil @deck.next_new_card
    assert_nil @deck.next_card
  end

  def make_review_card(card, due_in: 1.hour.ago)
    card.update!(state: 2, due_at: due_in, reps: 5, stability: 10, difficulty: 5, first_review_date: 3.days.ago)
    card
  end

  test "words_studied_today counts distinct words, separate from the new-word count" do
    review_card = make_review_card(@deck.flashcards.where(state: 0).first)
    review_card.review!(3)
    assert_equal 1, @deck.words_studied_today
    assert_equal 0, @deck.new_cards_today

    new_card = @deck.next_new_card
    new_card.review!(3)
    assert_equal 1, @deck.new_cards_today
    assert_equal 2, @deck.words_studied_today
  end

  test "due review cards have priority over new words" do
    review_card = make_review_card(@deck.flashcards.where(state: 0).first)

    assert_equal review_card, @deck.next_card
  end

  test "among due review cards, ones with more tries are served first" do
    card_a = make_review_card(@deck.flashcards.where(state: 0).first, due_in: 1.hour.ago)
    card_a.update!(reps: 3)
    card_b = make_review_card(@deck.flashcards.where(state: 0).second, due_in: 5.minutes.ago)
    card_b.update!(reps: 9)

    assert_equal card_b, @deck.next_card
  end

  test "pending Again/Hard cards are served even after the daily limit is reached" do
    @deck.update!(daily_review_goal: 1)
    make_review_card(@deck.flashcards.where(state: 0).first).review!(3)
    assert_equal 0, @deck.study_remaining_today

    pending = @deck.flashcards.where(state: 0).first
    pending.update!(state: 1, due_at: 1.minute.ago, reps: 2, stability: 3, difficulty: 5, first_review_date: 3.days.ago)

    assert_equal pending, @deck.next_card
  end

  test "cards rated Again come back during the session, in between new cards" do
    travel_to(Time.zone.local(2026, 8, 3, 9, 0, 0)) do
      card = @deck.next_card
      assert_not_nil card
      card.review!(1) # Again -> learning, due in ~10s

      assert_not @deck.due_cards.include?(card)
      assert_not_equal card, @deck.next_card

      travel 30.seconds
      assert_equal card, @deck.next_card
    end
  end

  test "session does not end while Again/Hard cards are still pending" do
    @deck.update!(daily_goal: 1)
    travel_to(Time.zone.local(2026, 8, 3, 9, 0, 0)) do
      card = @deck.next_card
      card.review!(1) # Again -> learning, not yet due

      # no new cards left (goal 1 reached), no due reviews, but the pending card
      # still comes back so the session continues.
      assert_equal card, @deck.next_card
    end
  end

  test "due review cards are served even after the new-card goal is reached" do
    @deck.update!(daily_goal: 1)
    due_card = @deck.flashcards.where(state: 0).first
    due_card.update!(state: 2, due_at: 1.hour.ago, reps: 5, stability: 10, difficulty: 5, first_review_date: 3.days.ago)

    assert_equal due_card, @deck.next_card
    due_card.review!(3)
    assert_equal 0, @deck.new_cards_today

    new_card = @deck.next_card
    assert_not_nil new_card
    new_card.review!(3)
    assert_equal 1, @deck.new_cards_today

    assert_equal 0, @deck.new_cards_remaining_today
    assert_nil @deck.next_card
  end
end
