class WorkoutTemplate < ApplicationRecord
  belongs_to :user
  has_many :workout_sessions, dependent: :nullify

  validates :name, :sets, :work_duration, :rest_duration, presence: true
  validates :sets, numericality: { greater_than: 0 }
  validates :work_duration, :rest_duration, numericality: { greater_than: 0 }
end
