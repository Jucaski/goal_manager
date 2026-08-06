require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "index shows the API token" do
    get settings_url
    assert_response :success
    assert_select "h1", "Settings"
    assert_select "h2", text: "API Token"
  end

  test "regenerate creates an API token" do
    user = users(:one)
    assert_nil user.api_token

    post regenerate_api_token_url
    assert_redirected_to settings_url
    assert_not_nil user.reload.api_token
  end

  test "regenerate changes the existing token" do
    user = users(:one)
    original = "original-token"
    user.update_column(:api_token, original)

    post regenerate_api_token_url
    user.reload
    assert_not_equal original, user.api_token
  end
end
