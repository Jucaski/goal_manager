class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def regenerate_api_token
    current_user.regenerate_api_token!
    redirect_to settings_path, notice: "API token #{current_user.api_token ? 'regenerated' : 'generated'}."
  end
end
