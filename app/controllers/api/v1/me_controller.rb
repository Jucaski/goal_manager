module Api
  module V1
    class MeController < BaseController
      def show
        render json: {
          email: current_user.email,
          server_time: Time.current.iso8601,
          date: Date.current.iso8601
        }
      end
    end
  end
end
