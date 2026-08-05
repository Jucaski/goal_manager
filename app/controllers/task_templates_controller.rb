class TaskTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [ :show, :edit, :update, :destroy ]

  def index
    @templates = current_user.task_templates.ordered
    @new_template = current_user.task_templates.build
  end

  def show
    @running_logs = current_user.time_logs.running.includes(:task)
    @today_logs = current_user.time_logs.for_range(Date.current, Date.current).where.not(ended_at: nil)
  end

  def new
    @template = current_user.task_templates.build
    @template.start_date ||= Date.current
    task = @template.tasks.build
    task.alarm_minutes_before ||= 5
  end

  def edit
  end

  def create
    @template = current_user.task_templates.build(template_params)

    if @template.save
      redirect_to scheduler_path, notice: "Template created."
    else
      @template.tasks.build if @template.tasks.empty?
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @template.update(template_params)
      redirect_to scheduler_path, notice: "Template updated."
    else
      @template.tasks.build if @template.tasks.empty?
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @template.destroy!
    redirect_to scheduler_path, notice: "Template deleted."
  end

  private

  def set_template
    @template = current_user.task_templates.find(params[:id])
  end

  def template_params
    params.require(:task_template).permit(
      :name, :start_date, :end_date,
      days_of_week: [],
      tasks_attributes: [ :id, :title, :tag, :ringtone_id, :alarm_minutes_before, :start_time, :duration_minutes, :_destroy ]
    )
  end
end
