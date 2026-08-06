require "test_helper"

class BodyProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "create saves body profile" do
    assert_nil users(:one).body_profile

    post body_profile_url, params: { body_profile: { gender: "female", height_cm: 165 } }

    profile = users(:one).body_profile
    assert_not_nil profile
    assert_equal "female", profile.gender
    assert_equal 165, profile.height_cm.to_f
    assert_redirected_to body_url
  end

  test "update changes existing profile" do
    users(:one).create_body_profile!(gender: "male", height_cm: 178)

    patch body_profile_url, params: { body_profile: { gender: "male", height_cm: 179 } }
    assert_equal 179, users(:one).body_profile.reload.height_cm.to_f
    assert_redirected_to body_url
  end

  test "invalid gender is rejected" do
    post body_profile_url, params: { body_profile: { gender: "other", height_cm: 165 } }

    profile = users(:one).body_profile
    assert profile.nil? || !profile.persisted?
    assert_redirected_to body_url
  end
end
