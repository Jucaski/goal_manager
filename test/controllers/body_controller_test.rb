require "test_helper"

class BodyControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "index shows profile, weight, and measurements sections" do
    get body_url
    assert_response :success
    assert_select "h1", "Body"
    assert_select "h2", text: "Body profile"
    assert_select "h2", text: "Weight"
    assert_select "h2", text: "Measurements"
  end

  test "index shows weight graph data" do
    users(:one).weight_entries.create!(weight: 70.0, date: Date.current - 1.day)
    users(:one).weight_entries.create!(weight: 69.8, date: Date.current)

    get body_url
    assert_response :success
    assert_select ".stat-bar-value", text: /70.0 kg/
    assert_select ".stat-bar-value", text: /69.8 kg/
  end

  test "index shows measurement graph for selected measurement" do
    users(:one).body_measurements.create!(date: Date.current, waist: 80)

    get body_url, params: { measurement: "waist" }
    assert_response :success
    assert_select ".stat-bar-value", text: /80.0 cm/
  end

  test "invalid measurement falls back to waist" do
    get body_url, params: { measurement: "not_a_measurement" }
    assert_response :success
  end
end
