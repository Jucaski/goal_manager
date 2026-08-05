require "test_helper"

class TimeLogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  def make_task
    template = users(:one).task_templates.create!(name: "Workout",
                                                  start_date: Date.current, days_of_week: [ 1 ])
    template.tasks.create!(title: "Gym", tag: "health", alarm_minutes_before: 5, start_time: Time.parse("07:00"), duration_minutes: 30)
  end

  test "start creates a time log for the task" do
    task = make_task

    assert_difference("users(:one).time_logs.count") do
      post start_time_logs_url, params: { task_id: task.id, date: Date.current.to_s }
    end

    assert_redirected_to scheduler_url(date: Date.current.to_s)
    assert task.reload.time_logs.running.any?
  end

  test "start does not create duplicate running logs" do
    task = make_task
    users(:one).time_logs.create!(task: task, started_at: Time.zone.now)

    assert_no_difference("users(:one).time_logs.count") do
      post start_time_logs_url, params: { task_id: task.id }
    end
  end

  test "stop saves elapsed time" do
    task = make_task
    log = users(:one).time_logs.create!(task: task, started_at: 2.hours.ago)

    patch stop_time_log_url(log)
    assert_redirected_to scheduler_url(date: log.started_at.to_date.to_s)
    assert_not_nil log.reload.ended_at
    assert_equal 120, log.duration_minutes
  end
end
