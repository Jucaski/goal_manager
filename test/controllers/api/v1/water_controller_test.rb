require "test_helper"

class Api::V1::WaterControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "returns today's total and entries" do
    @user.water_entries.create!(amount_ml: 250, date: Date.current)
    @user.water_entries.create!(amount_ml: 500, date: Date.current)
    @user.water_entries.create!(amount_ml: 300, date: Date.current - 1.day)

    get "/api/v1/water", headers: auth_headers
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 750, body["total_ml"]
    assert_equal 2, body["entries"].size
  end

  test "creates a water entry and returns new total" do
    assert_difference("@user.water_entries.count", 1) do
      post "/api/v1/water", params: { amount_ml: 400 }, headers: auth_headers
    end
    assert_response :created

    body = JSON.parse(response.body)
    assert_equal 400, body["amount_ml"]
    assert_equal 400, body["total_ml"]
  end

  test "rejects non-positive amounts" do
    post "/api/v1/water", params: { amount_ml: 0 }, headers: auth_headers
    assert_response :unprocessable_content
  end
end
