require "test_helper"

class BodyMeasurementsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "create saves measurements" do
    assert_difference("users(:one).body_measurements.count", 1) do
      post body_measurements_url, params: {
        body_measurement: { date: Date.current.to_s, waist: 80, bust: 90, neck: 35 }
      }
    end

    m = users(:one).body_measurements.last
    assert_equal 80, m.waist.to_f
    assert_equal 90, m.bust.to_f
    assert_equal 35, m.neck.to_f
  end

  test "create with no measurements is rejected" do
    assert_no_difference("users(:one).body_measurements.count") do
      post body_measurements_url, params: { body_measurement: { date: Date.current.to_s } }
    end
    assert_redirected_to body_url
  end

  test "duplicate date is rejected" do
    users(:one).body_measurements.create!(date: Date.current, waist: 80)

    assert_no_difference("users(:one).body_measurements.count") do
      post body_measurements_url, params: { body_measurement: { date: Date.current.to_s, waist: 79 } }
    end
  end

  test "destroy removes an entry" do
    m = users(:one).body_measurements.create!(date: Date.current, waist: 80)

    assert_difference("users(:one).body_measurements.count", -1) do
      delete body_measurement_url(m)
    end
    assert_redirected_to body_url
  end
end
