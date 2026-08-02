require "test_helper"

class BalancesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "should get index" do
    get balances_index_url
    assert_response :success
  end
end
