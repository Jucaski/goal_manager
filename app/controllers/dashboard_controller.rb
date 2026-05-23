class DashboardController < ApplicationController
  before_action :authenticate_user!
  def settings
  end
end
