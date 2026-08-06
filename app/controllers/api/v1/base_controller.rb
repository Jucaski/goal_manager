module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_token!

      private

      def authenticate_api_token!
        token = request.headers["Authorization"].to_s.sub(/\ABearer\s+/i, "").presence
        @current_user = token && User.find_by(api_token: token)

        render json: { error: "unauthorized" }, status: :unauthorized unless @current_user
      end

      attr_reader :current_user
    end
  end
end
