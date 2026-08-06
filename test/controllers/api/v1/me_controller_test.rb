require "test_helper"

class Api::V1::MeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "returns user info with a valid token" do
    get "/api/v1/me", headers: auth_headers(@user)
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal @user.email, body["email"]
    assert body["server_time"].present?
    assert body["date"].present?
  end
end
