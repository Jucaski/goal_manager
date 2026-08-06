require "test_helper"

class Api::V1::WeightControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "returns latest and recent weights" do
    @user.weight_entries.create!(weight: 72.0, date: Date.current - 1.day)
    @user.weight_entries.create!(weight: 71.5, date: Date.current)

    get "/api/v1/weight", headers: auth_headers
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 71.5, body["latest"]["weight"].to_f
    assert_equal 2, body["recent"].size
  end

  test "creates a weight entry for today" do
    assert_difference("@user.weight_entries.count", 1) do
      post "/api/v1/weight", params: { weight: 70.2 }, headers: auth_headers
    end
    assert_response :created
    assert_equal 70.2, JSON.parse(response.body)["weight"].to_f
  end

  test "rejects non-positive weight" do
    post "/api/v1/weight", params: { weight: 0 }, headers: auth_headers
    assert_response :unprocessable_content
  end
end
