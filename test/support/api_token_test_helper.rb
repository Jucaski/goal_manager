module ApiTokenTestHelper
  private

  def auth_headers(user = nil)
    user ||= users(:one)
    user.regenerate_api_token! if user.api_token.blank?
    { "Authorization" => "Bearer #{user.api_token}" }
  end
end
