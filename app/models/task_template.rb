class TaskTemplate < ApplicationRecord
  belongs_to :user

  has_many :tasks, dependent: :destroy
  has_many :time_logs, through: :tasks, dependent: :destroy

  accepts_nested_attributes_for :tasks, allow_destroy: true, reject_if: :reject_task?

  validates :name, :start_date, presence: true
  validate :at_least_one_day

  scope :ordered, -> { order(:name) }

  def occurs_on?(date)
    return false if start_date.nil? || date < start_date
    return false if end_date.present? && date > end_date

    Array(days_of_week).map(&:to_i).include?(date.wday)
  end

  def days_labels
    Array(days_of_week).map { |d| Date::DAYNAMES[d.to_i] }
  end

  def total_minutes_between(from, to)
    time_logs.for_range(from, to).sum(&:duration_minutes)
  end

  private

  def reject_task?(attributes)
    attributes["start_time"].blank?
  end

  def at_least_one_day
    errors.add(:days_of_week, "select at least one day") if Array(days_of_week).reject(&:blank?).empty?
  end
end
