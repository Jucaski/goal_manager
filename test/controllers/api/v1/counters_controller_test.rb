require "test_helper"

class Api::V1::CountersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "returns current goal and other counters" do
    current_goal = @user.counters.create!(
      title: "Current Goal", tag: Counter::CURRENT_GOAL_TAG, mode: "duration",
      start_date: Date.current, duration_value: 30, duration_unit: "days",
      end_date: Date.current + 30.days, direction: "descending", units: [ "days" ]
    )
    @user.counters.create!(
      title: "Reading", tag: "reading", mode: "duration",
      start_date: Date.current, duration_value: 100, duration_unit: "days",
      end_date: Date.current + 100.days, direction: "ascending", units: [ "days" ]
    )

    get "/api/v1/counters", headers: auth_headers
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal "Current Goal", body["current_goal"]["title"]
    assert_equal 1, body["counters"].size
    assert_equal "Reading", body["counters"].first["title"]
    assert_equal [ "days" ], body["counters"].first["units"].map { |u| u["unit"] }
  end
end
