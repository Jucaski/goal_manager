class WorkoutSession < ApplicationRecord
  belongs_to :user
  belongs_to :workout_template, optional: true

  validates :date, :sets, :work_duration, :rest_duration, presence: true
  validates :is_running, inclusion: { in: [true, false] }
  def start_time
    date
  end
end
