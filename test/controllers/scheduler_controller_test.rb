require "test_helper"

class SchedulerControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  def make_template(user)
    template = user.task_templates.create!(
      name: "Workout",
      start_date: Date.current - 1.week, end_date: Date.current + 1.month,
      days_of_week: [ 1, 3, 5 ]
    )
    template.tasks.create!(title: "Gym", tag: "health", alarm_minutes_before: 5, start_time: Time.parse("07:00"), duration_minutes: 45)
    template.tasks.create!(title: "Yoga", tag: "health", alarm_minutes_before: 10, start_time: Time.parse("18:00"), duration_minutes: 30)
    template
  end

  test "index shows day view" do
    get scheduler_url
    assert_response :success
    assert_select "h1", "Schedule"
  end

  test "day view shows tasks for today" do
    make_template(users(:one))

    get scheduler_url, params: { view: "day", date: Date.current.to_s }
    assert_response :success
  end

  test "week view shows tasks" do
    make_template(users(:one))

    get scheduler_url, params: { view: "week" }
    assert_response :success
    assert_select ".scheduler-week-table"
  end

  test "month view shows tasks" do
    make_template(users(:one))

    get scheduler_url, params: { view: "month" }
    assert_response :success
    assert_select ".scheduler-month-table"
  end

  test "stats view renders charts" do
    template = make_template(users(:one))
    users(:one).time_logs.create!(task: template.tasks.first, started_at: 2.hours.ago, ended_at: 1.hour.ago)

    get scheduler_url, params: { view: "stats" }
    assert_response :success
    assert_select "canvas"
  end

  test "alarms endpoint returns today's tasks with wall-clock start" do
    template = users(:one).task_templates.create!(
      name: "Workout",
      start_date: Date.current - 1.week, end_date: Date.current + 1.week,
      days_of_week: [ Date.current.wday ]
    )
    template.tasks.create!(title: "Gym", tag: "health", alarm_minutes_before: 10, start_time: "07:00", duration_minutes: 45)

    get scheduler_alarms_url
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body.size
    assert_equal "Gym", body.first["title"]
    assert_equal "health", body.first["tag"]
    assert_equal 10, body.first["alarm_minutes_before"]
    assert_equal 7, body.first["start"]["hour"]
    assert_equal 0, body.first["start"]["min"]
    assert_equal Date.current.day, body.first["start"]["day"]
  end
end
