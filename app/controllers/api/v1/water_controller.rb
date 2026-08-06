module Api
  module V1
    class WaterController < BaseController
      def show
        date = params[:date].presence&.to_date || Date.current
        entries = current_user.water_entries.for_date(date)

        render json: {
          date: date.iso8601,
          total_ml: entries.sum(:amount_ml),
          entries: entries.map { |e| { id: e.id, amount_ml: e.amount_ml } }
        }
      end

      def create
        date = params[:date].presence&.to_date || Date.current
        amount = params[:amount_ml].to_i

        if amount <= 0
          return render json: { error: "amount_ml must be greater than 0" }, status: :unprocessable_content
        end

        entry = current_user.water_entries.create!(amount_ml: amount, date: date)

        render json: {
          id: entry.id,
          amount_ml: entry.amount_ml,
          date: entry.date.iso8601,
          total_ml: current_user.water_entries.for_date(date).sum(:amount_ml)
        }, status: :created
      end
    end
  end
end
