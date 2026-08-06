module Api
  module V1
    class WeightController < BaseController
      def show
        entries = current_user.weight_entries.ordered.limit(7)
        latest = entries.first

        render json: {
          latest: latest && weight_payload(latest),
          recent: entries.map { |e| weight_payload(e) }
        }
      end

      def create
        weight = params[:weight]

        if weight.blank? || weight.to_f <= 0
          return render json: { error: "weight must be greater than 0" }, status: :unprocessable_content
        end

        entry = current_user.weight_entries.find_or_initialize_by(date: params[:date].presence&.to_date || Date.current)
        entry.weight = weight.to_f
        entry.save!

        render json: weight_payload(entry), status: :created
      end

      private

      def weight_payload(entry)
        {
          id: entry.id,
          date: entry.date.iso8601,
          weight: entry.weight.to_f
        }
      end
    end
  end
end
