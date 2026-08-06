class TaskCompletion < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :date, presence: true
  validates :task_id, uniqueness: { scope: :date }
end
