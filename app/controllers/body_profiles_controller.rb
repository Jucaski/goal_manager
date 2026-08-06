class BodyProfilesController < ApplicationController
  before_action :authenticate_user!

  def create
    @profile = current_user.build_body_profile(profile_params)
    save_or_redirect
  end

  def update
    @profile = current_user.body_profile || current_user.build_body_profile
    @profile.assign_attributes(profile_params)
    save_or_redirect
  end

  private

  def save_or_redirect
    if @profile.save
      redirect_to body_path, notice: "Body profile saved."
    else
      redirect_to body_path, alert: @profile.errors.full_messages.to_sentence
    end
  end

  def profile_params
    params.require(:body_profile).permit(:gender, :height_cm)
  end
end
