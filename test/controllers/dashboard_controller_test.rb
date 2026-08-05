require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def make_deck(user, name, word)
    ChineseWord.create!(word: word, pinyin: "ài", part_of_speech: "动", translation: "to love", level: 1)
    deck = user.flashcard_decks.create!(name: name, kind: "configurable", front_fields: [ "word" ], back_fields: [ "translation" ], levels: [ 1 ])
    deck.generate_cards!
    deck.next_card.review!(3)
    deck
  end

  test "index shows phases and study activity for each deck separately" do
    user = users(:one)
    sign_in user
    make_deck(user, "Deck A", "爱")
    make_deck(user, "Deck B", "八")

    get root_url
    assert_response :success
    assert_select "h2", text: "Deck A"
    assert_select "h2", text: "Deck B"
    assert_select ".heatmap", count: 2
    assert_select ".stat-label", text: /Young/, count: 2
  end

  test "index omits flashcard sections when the user has no decks with cards" do
    sign_in users(:one)

    get root_url
    assert_response :success
    assert_select ".heatmap", count: 0
  end

  test "index shows water intake section with today's total" do
    user = users(:one)
    sign_in user
    user.water_entries.create!(amount_ml: 250, date: Date.current)
    user.water_entries.create!(amount_ml: 500, date: Date.current)
    user.water_entries.create!(amount_ml: 300, date: Date.current - 1.day)

    get root_url
    assert_response :success
    assert_select "h2", text: /Water/
    assert_match(/Today:.*750 ml/, response.body)
    assert_select ".stat-bar-fill", minimum: 1
  end
end
