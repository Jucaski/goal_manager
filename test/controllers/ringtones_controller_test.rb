require "test_helper"

class RingtonesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "index shows upload form" do
    get ringtones_url
    assert_response :success
    assert_select "h1", "Ringtones"
  end

  test "create with invalid audio re-renders index with errors" do
    assert_no_difference("users(:one).ringtones.count") do
      post ringtones_url, params: { ringtone: { name: "", audio: nil } }
    end
    assert_response :unprocessable_content
    assert_select "form"
    assert_select ".alert-danger"
  end
end
