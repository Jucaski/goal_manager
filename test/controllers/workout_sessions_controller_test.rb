require "test_helper"

class WorkoutSessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "running workout creates a time log for the Run task" do
    assert_difference("users(:one).time_logs.count", 1) do
      assert_difference("users(:one).workout_sessions.count", 1) do
        post workout_sessions_url, params: {
          workout_session: { sets: 5, work_duration: 60, rest_duration: 30, is_running: "true" }
        }
      end
    end

    log = users(:one).time_logs.last
    assert_equal "Run", log.task.title
    assert_equal "running", log.task.tag
    assert_equal 8, log.duration_minutes
  end

  test "non-running workout does not create a time log" do
    assert_no_difference("users(:one).time_logs.count") do
      post workout_sessions_url, params: {
        workout_session: { sets: 5, work_duration: 60, rest_duration: 30, is_running: "false" }
      }
    end
  end

  test "repeated running workouts reuse the same Run task" do
    post workout_sessions_url, params: { workout_session: { sets: 3, work_duration: 60, rest_duration: 30, is_running: "true" } }
    first_task = users(:one).time_logs.last.task

    post workout_sessions_url, params: { workout_session: { sets: 4, work_duration: 60, rest_duration: 30, is_running: "true" } }
    second_task = users(:one).time_logs.last.task

    assert_equal first_task, second_task
    assert_equal 1, users(:one).tasks.where(title: "Run").count
  end
end
