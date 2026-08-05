require "test_helper"

class WaterEntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "create adds a water entry for today" do
    assert_difference("users(:one).water_entries.count", 1) do
      post water_entries_url, params: { water_entry: { amount_ml: 250 } }
    end

    entry = users(:one).water_entries.last
    assert_equal 250, entry.amount_ml
    assert_equal Date.current, entry.date
    assert_redirected_to root_url
  end

  test "create with a specific date" do
    post water_entries_url, params: { water_entry: { amount_ml: 500, date: Date.current - 1.day } }
    assert_equal Date.current - 1.day, users(:one).water_entries.last.date
  end

  test "create with invalid amount redirects with alert" do
    assert_no_difference("users(:one).water_entries.count") do
      post water_entries_url, params: { water_entry: { amount_ml: 0 } }
    end
    assert_redirected_to root_url
  end

  test "destroy removes a water entry" do
    entry = users(:one).water_entries.create!(amount_ml: 250, date: Date.current)

    assert_difference("users(:one).water_entries.count", -1) do
      delete water_entry_url(entry)
    end
    assert_redirected_to root_url
  end
end
