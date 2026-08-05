class TimeLog < ApplicationRecord
  belongs_to :user
  belongs_to :task

  delegate :task_template, to: :task, allow_nil: true

  scope :ordered, -> { order(started_at: :desc) }
  scope :for_range, ->(from, to) { where(started_at: from.beginning_of_day..to.end_of_day) }
  scope :running, -> { where(ended_at: nil) }

  def stop!
    return if ended_at.present?

    update!(ended_at: Time.current)
  end

  def duration_minutes
    return 0 if ended_at.nil?

    ((ended_at - started_at) / 60).round
  end
end
