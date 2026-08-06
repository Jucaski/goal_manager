require "test_helper"

class Api::V1::ScheduleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @template = @user.task_templates.create!(
      name: "Morning", start_date: Date.current - 1.week,
      end_date: Date.current + 1.week, days_of_week: [ Date.current.wday ]
    )
    @task = @template.tasks.create!(title: "Gym", tag: "health", start_time: "07:00", duration_minutes: 45)
    @task2 = @template.tasks.create!(title: "Yoga", start_time: "18:00", duration_minutes: 30)
  end

  test "returns today's tasks" do
    get "/api/v1/schedule/today", headers: auth_headers
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 2, body["tasks"].size
    first = body["tasks"].first
    assert_equal "Gym", first["title"]
    assert_equal "07:00", first["start_time"]
    assert_equal "07:45", first["end_time"]
    assert_equal 45, first["duration_minutes"]
    assert_equal "health", first["tag"]
  end

  test "returns next upcoming task" do
    template = @user.task_templates.create!(name: "Later", start_date: Date.current,
                                            end_date: Date.current, days_of_week: [ Date.current.wday ])
    template.tasks.create!(title: "Read", start_time: (Time.current + 1.hour).strftime("%H:%M"), duration_minutes: 30)

    get "/api/v1/schedule/today", headers: auth_headers
    body = JSON.parse(response.body)
    assert body["next_task"].present?
    assert_equal "Read", body["next_task"]["title"]
  end

  test "includes alarm minutes in payload" do
    get "/api/v1/schedule/today", headers: auth_headers
    body = JSON.parse(response.body)
    assert_equal 0, body["tasks"].first["alarm_minutes_before"]
  end

  test "completed tasks are excluded from today's list and next task" do
    @task.task_completions.create!(date: Date.current)

    get "/api/v1/schedule/today", headers: auth_headers
    body = JSON.parse(response.body)

    titles = body["tasks"].map { |t| t["title"] }
    assert_equal [ "Yoga" ], titles
    assert_not_equal "Gym", body.dig("next_task", "title")
  end

  test "completing a task removes it from today's list" do
    post "/api/v1/schedule/tasks/#{@task.id}/complete", headers: auth_headers
    assert_response :success
    assert_equal true, JSON.parse(response.body)["completed"]

    get "/api/v1/schedule/today", headers: auth_headers
    titles = JSON.parse(response.body)["tasks"].map { |t| t["title"] }
    assert_equal [ "Yoga" ], titles
  end

  test "uncompleting a task restores it to today's list" do
    @task.task_completions.create!(date: Date.current)

    delete "/api/v1/schedule/tasks/#{@task.id}/complete", headers: auth_headers
    assert_response :success
    assert_equal false, JSON.parse(response.body)["completed"]

    get "/api/v1/schedule/today", headers: auth_headers
    titles = JSON.parse(response.body)["tasks"].map { |t| t["title"] }
    assert_equal [ "Gym", "Yoga" ], titles
  end
end
