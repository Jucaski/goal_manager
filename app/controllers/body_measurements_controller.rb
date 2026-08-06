class BodyMeasurementsController < ApplicationController
  before_action :authenticate_user!

  def create
    @measurement = current_user.body_measurements.build(measurement_params)

    if @measurement.save
      redirect_to body_path, notice: "Measurements saved."
    else
      redirect_to body_path, alert: @measurement.errors.full_messages.to_sentence
    end
  end

  def destroy
    @measurement = current_user.body_measurements.find(params[:id])
    @measurement.destroy!
    redirect_to body_path, notice: "Measurement entry removed."
  end

  private

  def measurement_params
    params.require(:body_measurement).permit(:date, BodyMeasurement::MEASUREMENTS.keys)
  end
end
