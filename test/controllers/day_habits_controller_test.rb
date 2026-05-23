require "test_helper"

class DayHabitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @day_habit = day_habits(:one)
  end

  test "should get index" do
    get day_habits_url
    assert_response :success
  end

  test "should get new" do
    get new_day_habit_url
    assert_response :success
  end

  test "should create day_habit" do
    assert_difference("DayHabit.count") do
      post day_habits_url, params: { day_habit: { date: @day_habit.date, habit_id: @day_habit.habit_id, rating: @day_habit.rating, user_id: @day_habit.user_id } }
    end

    assert_redirected_to day_habit_url(DayHabit.last)
  end

  test "should show day_habit" do
    get day_habit_url(@day_habit)
    assert_response :success
  end

  test "should get edit" do
    get edit_day_habit_url(@day_habit)
    assert_response :success
  end

  test "should update day_habit" do
    patch day_habit_url(@day_habit), params: { day_habit: { date: @day_habit.date, habit_id: @day_habit.habit_id, rating: @day_habit.rating, user_id: @day_habit.user_id } }
    assert_redirected_to day_habit_url(@day_habit)
  end

  test "should destroy day_habit" do
    assert_difference("DayHabit.count", -1) do
      delete day_habit_url(@day_habit)
    end

    assert_redirected_to day_habits_url
  end
end
