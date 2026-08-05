class WorkoutSession < ApplicationRecord
  belongs_to :user
  belongs_to :workout_template, optional: true

  validates :date, :sets, :work_duration, :rest_duration, presence: true
  validates :is_running, inclusion: { in: [ true, false ] }

  def start_time
    date
  end

  # Total elapsed seconds the timer ran: the timer runs a work interval and a
  # rest interval for every set (rest included after the final set too).
  def total_seconds
    sets.to_i * (work_duration.to_i + rest_duration.to_i)
  end
end
