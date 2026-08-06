require "test_helper"

class Api::V1::HabitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @habit = @user.habits.create!(title: "Read", position: 1)
    @habit2 = @user.habits.create!(title: "Run", position: 2)
  end

  test "returns today's habits with ratings" do
    @user.day_habits.create!(habit: @habit, date: Date.current, rating: 8)

    get "/api/v1/habits/today", headers: auth_headers
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 3, body["habits"].size
    read = body["habits"].find { |h| h["title"] == "Read" }
    assert_equal 8, read["rating"]
    run = body["habits"].find { |h| h["title"] == "Run" }
    assert_nil run["rating"]
  end

  test "updates a habit rating" do
    patch "/api/v1/habits/#{@habit.id}/rating", params: { rating: 7 }, headers: auth_headers
    assert_response :success

    assert_equal 7, @user.day_habits.find_by(habit: @habit, date: Date.current).rating
    assert_equal 7, JSON.parse(response.body)["rating"]
  end

  test "clears a habit rating with rating 0" do
    @user.day_habits.create!(habit: @habit, date: Date.current, rating: 5)

    patch "/api/v1/habits/#{@habit.id}/rating", params: { rating: 0 }, headers: auth_headers
    assert_response :success
    assert_nil JSON.parse(response.body)["rating"]
    assert_nil @user.day_habits.find_by(habit: @habit, date: Date.current)
  end

  test "rejects rating outside 0-10" do
    patch "/api/v1/habits/#{@habit.id}/rating", params: { rating: 11 }, headers: auth_headers
    assert_response :unprocessable_content
  end

  test "rejects unknown habit" do
    patch "/api/v1/habits/999999/rating", params: { rating: 5 }, headers: auth_headers
    assert_response :not_found
  end
end
