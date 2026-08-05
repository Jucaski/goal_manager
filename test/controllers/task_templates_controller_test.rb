require "test_helper"

class TaskTemplatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "index shows templates" do
    get task_templates_url
    assert_response :success
    assert_select "h1", "Templates"
  end

  test "create template with multiple tasks" do
    assert_difference("users(:one).task_templates.count") do
      post task_templates_url, params: {
        task_template: {
          name: "Reading", start_date: Date.current.to_s, days_of_week: [ "1", "2", "3" ],
          tasks_attributes: {
            "0" => { title: "Evening reading", tag: "study", alarm_minutes_before: "10", start_time: "21:00", duration_minutes: "30" },
            "1" => { title: "Morning reading", tag: "study", alarm_minutes_before: "5", start_time: "07:00", duration_minutes: "15" }
          }
        }
      }
    end

    template = users(:one).task_templates.last
    assert_redirected_to scheduler_url
    assert_equal [ 1, 2, 3 ], template.days_of_week.map(&:to_i)
    assert_equal 2, template.tasks.count
    assert_equal "Evening reading", template.tasks.first.title
    assert_equal 10, template.tasks.first.alarm_minutes_before
    assert_equal "study", template.tasks.first.tag
  end

  test "template without name is invalid" do
    assert_no_difference("users(:one).task_templates.count") do
      post task_templates_url, params: { task_template: { name: "", start_date: Date.current.to_s, days_of_week: [ 1 ] } }
    end
    assert_response :unprocessable_content
  end

  test "update template" do
    template = users(:one).task_templates.create!(name: "Old",
                                                  start_date: Date.current, days_of_week: [ 1 ])

    patch task_template_url(template), params: { task_template: { name: "New" } }
    assert_redirected_to scheduler_url
    assert_equal "New", template.reload.name
  end

  test "destroy deletes template and tasks" do
    template = users(:one).task_templates.create!(name: "Temp",
                                                  start_date: Date.current, days_of_week: [ 1 ])
    template.tasks.create!(title: "Task", start_time: Time.parse("08:00"), duration_minutes: 30)

    assert_difference("users(:one).task_templates.count", -1) do
      assert_difference("Task.count", -1) do
        delete task_template_url(template)
      end
    end
    assert_redirected_to scheduler_url
  end
end
