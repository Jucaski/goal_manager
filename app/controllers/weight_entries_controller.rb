class WeightEntriesController < ApplicationController
  before_action :authenticate_user!

  def create
    @entry = current_user.weight_entries.build(weight_entry_params)

    if @entry.save
      redirect_to body_path, notice: "Weight saved."
    else
      redirect_to body_path, alert: @entry.errors.full_messages.to_sentence
    end
  end

  def destroy
    @entry = current_user.weight_entries.find(params[:id])
    @entry.destroy!
    redirect_to body_path, notice: "Weight entry removed."
  end

  private

  def weight_entry_params
    params.require(:weight_entry).permit(:weight, :date)
  end
end
