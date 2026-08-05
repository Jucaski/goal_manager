class RingtonesController < ApplicationController
  before_action :authenticate_user!

  def index
    @ringtones = current_user.ringtones.ordered
    @new_ringtone = current_user.ringtones.build
  end

  def create
    @ringtone = current_user.ringtones.build(ringtone_params)

    if @ringtone.save
      redirect_to scheduler_path(anchor: "ringtones"), notice: "Ringtone uploaded."
    else
      @ringtones = current_user.ringtones.ordered
      @new_ringtone = @ringtone
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    @ringtone = current_user.ringtones.find(params[:id])
    @ringtone.destroy!
    redirect_to scheduler_path(anchor: "ringtones"), notice: "Ringtone deleted."
  end

  private

  def ringtone_params
    params.require(:ringtone).permit(:name, :audio)
  end
end
