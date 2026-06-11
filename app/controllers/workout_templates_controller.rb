class WorkoutTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [:edit, :update, :destroy]

  def index
    @templates = current_user.workout_templates.order(created_at: :desc)
  end

  def new
    @template = current_user.workout_templates.build
  end

  def create
    @template = current_user.workout_templates.build(template_params)
    if @template.save
      redirect_to workout_templates_path, notice: "Workout created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end
  def update
    if @template.update(template_params)
      redirect_to workout_templates_path, notice: "Updated."
    else
      render :edit
    end
  end

  def destroy
    @template.destroy
    redirect_to workout_templates_path, notice: "Deleted."
  end

  private

  def set_template
    @template = current_user.workout_templates.find(params[:id])
  end

  def template_params
    params.require(:workout_template).permit(:name, :sets, :work_duration, :rest_duration, :is_running)
  end
end
