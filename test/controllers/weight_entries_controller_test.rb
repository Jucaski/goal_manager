require "test_helper"

class WeightEntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "create saves a weight entry" do
    assert_difference("users(:one).weight_entries.count", 1) do
      post weight_entries_url, params: { weight_entry: { weight: 70.5, date: Date.current.to_s } }
    end

    assert_redirected_to body_url
    assert_equal 70.5, users(:one).weight_entries.last.weight.to_f
  end

  test "create without date defaults to today" do
    post weight_entries_url, params: { weight_entry: { weight: 71 } }
    assert_equal Date.current, users(:one).weight_entries.last.date
  end

  test "create with duplicate date is rejected" do
    users(:one).weight_entries.create!(weight: 70, date: Date.current)

    assert_no_difference("users(:one).weight_entries.count") do
      post weight_entries_url, params: { weight_entry: { weight: 71, date: Date.current.to_s } }
    end
    assert_redirected_to body_url
  end

  test "destroy removes a weight entry" do
    entry = users(:one).weight_entries.create!(weight: 70, date: Date.current)

    assert_difference("users(:one).weight_entries.count", -1) do
      delete weight_entry_url(entry)
    end
    assert_redirected_to body_url
  end
end
