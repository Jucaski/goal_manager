class WaterEntriesController < ApplicationController
  before_action :authenticate_user!

  def create
    @entry = current_user.water_entries.build(water_entry_params)
    @entry.date ||= Date.current

    if @entry.save
      redirect_to root_path, notice: "Added #{@entry.amount_ml} ml of water."
    else
      redirect_to root_path, alert: "Could not add water: #{@entry.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @entry = current_user.water_entries.find(params[:id])
    @entry.destroy!
    redirect_to root_path, notice: "Water entry removed."
  end

  private

  def water_entry_params
    params.require(:water_entry).permit(:amount_ml, :date)
  end
end
