class Task < ApplicationRecord
  belongs_to :user
  belongs_to :task_template
  belongs_to :ringtone, optional: true

  has_many :time_logs, dependent: :destroy

  ALARM_OPTIONS = [ [ "At the start", 0 ], [ "5 minutes before", 5 ], [ "10 minutes before", 10 ], [ "15 minutes before", 15 ] ].freeze

  before_validation :inherit_user_from_template

  validates :title, :start_time, presence: true
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }
  validates :alarm_minutes_before, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:start_time) }

  def start_datetime(date)
    date.in_time_zone.change(hour: start_time.hour, min: start_time.min)
  end

  def end_datetime(date)
    start_datetime(date) + duration_minutes.minutes
  end

  def alarm_datetime(date)
    start_datetime(date) - alarm_minutes_before.minutes
  end

  def active_time_log_for(date)
    time_logs.where(started_at: date.beginning_of_day..date.end_of_day, ended_at: nil).first
  end

  def time_logs_for(date)
    time_logs.where(started_at: date.beginning_of_day..date.end_of_day)
  end

  def total_minutes_between(from, to)
    time_logs.for_range(from, to).sum(&:duration_minutes)
  end

  private

  def inherit_user_from_template
    self.user_id ||= task_template&.user_id
  end
end
