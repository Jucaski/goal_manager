require "test_helper"

class FlashcardDecksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
    ChineseWord.create!(word: "爱", pinyin: "ài", part_of_speech: "动", translation: "to love", level: 1)
  end

  test "index shows decks" do
    get flashcard_decks_url
    assert_response :success
  end

  test "create deck and generate cards" do
    assert_difference("FlashcardDeck.count") do
      post flashcard_decks_url, params: { flashcard_deck: { name: "HSK 1", kind: "configurable", front_fields: [ "word" ], back_fields: [ "translation" ], levels: [ "1" ] } }
    end
    assert_redirected_to flashcard_deck_url(FlashcardDeck.last)
  end

  test "generate_cards creates cards for matching level" do
    deck = users(:one).flashcard_decks.create!(name: "HSK 1", kind: "configurable", front_fields: [ "word" ], back_fields: [ "translation" ], levels: [ 1 ])

    assert_difference("deck.flashcards.count") do
      post generate_cards_flashcard_deck_url(deck)
    end
    assert_redirected_to flashcard_deck_url(deck)
  end

  test "study shows a card" do
    deck = users(:one).flashcard_decks.create!(name: "HSK 1", kind: "configurable", front_fields: [ "word" ], back_fields: [ "translation" ], levels: [ 1 ])
    deck.generate_cards!

    get study_flashcard_deck_url(deck)
    assert_response :success
    assert_select "h1", /HSK 1/
  end

  test "review schedules the card" do
    deck = users(:one).flashcard_decks.create!(name: "HSK 1", kind: "configurable", front_fields: [ "word" ], back_fields: [ "translation" ], levels: [ 1 ])
    deck.generate_cards!
    card = deck.next_card

    post review_flashcard_url(card), params: { rating: 3 }
    assert_redirected_to study_flashcard_deck_url(deck)
    assert_equal 1, card.reload.reps
    assert_equal 1, card.review_logs.count
  end

  test "summary shows stats and heatmap" do
    deck = users(:one).flashcard_decks.create!(name: "HSK 1", kind: "configurable", front_fields: [ "word" ], back_fields: [ "translation" ], levels: [ 1 ])
    deck.generate_cards!
    card = deck.next_card
    card.review!(3)

    get summary_flashcard_deck_url(deck)
    assert_response :success
    assert_select "h1", /Summary/
    assert_select ".stat-card", minimum: 6
    assert_select ".heatmap", count: 1
  end

  test "review on a writing deck redirects back to the writing study page" do
    Hanzi.create!(character: "爱", strokes: [ "M 1 1" ], medians: [ [ [ 0, 0 ], [ 1, 1 ] ] ])
    deck = users(:one).flashcard_decks.create!(name: "Writing", kind: "writing", levels: [ 1 ])
    deck.generate_cards!
    card = deck.next_card

    post review_flashcard_url(card), params: { rating: 2 }
    assert_redirected_to study_writing_flashcard_deck_url(deck)
  end

  test "study_writing shows a card with drawing canvas" do
    Hanzi.create!(character: "爱", strokes: [ "M 1 1" ], medians: [ [ [ 0, 0 ], [ 1, 1 ] ] ])
    deck = users(:one).flashcard_decks.create!(name: "Writing", kind: "writing", levels: [ 1 ])
    deck.generate_cards!

    get study_writing_flashcard_deck_url(deck)
    assert_response :success
    assert_select "[data-controller=writing-card]"
    assert_select "script[src*='hanzi-writer']"
  end

  test "hanzi endpoint returns stroke data" do
    Hanzi.create!(character: "爱", strokes: [ "M 1 1" ], medians: [ [ [ 0, 0 ], [ 1, 1 ] ] ])

    get hanzi_url("爱")
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal [ "M 1 1" ], body["strokes"]
  end
end
