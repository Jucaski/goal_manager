require "test_helper"

class Api::V1::BaseControllerTest < ActionDispatch::IntegrationTest
  test "requests without a token return 401" do
    get "/api/v1/me"
    assert_response :unauthorized
    assert_equal({ "error" => "unauthorized" }, JSON.parse(response.body))
  end

  test "requests with an invalid token return 401" do
    get "/api/v1/me", headers: { "Authorization" => "Bearer invalid-token" }
    assert_response :unauthorized
  end
end
