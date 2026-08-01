class Counter < ApplicationRecord
  CURRENT_GOAL_TAG = "current_goal"

  DIRECTIONS = [ "ascending", "descending" ].freeze
  UNITS = [ "days", "weeks", "months" ].freeze
  MODES = [ "duration", "dates" ].freeze

  belongs_to :user

  before_validation :normalize_dates
  before_validation :clean_units

  validates :title, presence: true
  validates :start_date, :end_date, presence: true
  validates :direction, inclusion: { in: DIRECTIONS }
  validates :mode, inclusion: { in: MODES }
  validates :duration_unit, inclusion: { in: UNITS }, allow_nil: true
  validate :end_date_after_start_date
  validate :at_least_one_unit

  scope :ordered, -> { order(created_at: :asc) }

  def current_goal?
    tag == CURRENT_GOAL_TAG
  end

  def count_from_today?
    mode == "duration"
  end

  def total_value_for(unit)
    diff_between(start_date, end_date, unit)
  end

  def value_for(unit)
    total = total_value_for(unit)
    value = if direction == "ascending"
      diff_between(start_date, Date.current, unit)
    else
      diff_between(Date.current, end_date, unit)
    end
    [ [ value, 0 ].max, total ].min
  end

  private

  def clean_units
    self.units = Array(units).reject(&:blank?) if units.present?
  end

  def normalize_dates
    self.mode ||= "duration"

    if count_from_today?
      self.start_date ||= Date.current
      self.end_date = start_date + duration_value.to_i.public_send(duration_unit || "days") if duration_value.to_i > 0
    end

    self.units ||= []
  end

  def diff_between(from, to, unit)
    return 0 if from.nil? || to.nil?

    case unit
    when "months"
      month_diff(from, to)
    when "weeks"
      ((to - from).to_i / 7.0).floor
    else
      (to - from).to_i
    end
  end

  def month_diff(from, to)
    (to.year - from.year) * 12 + (to.month - from.month) - (to.day < from.day ? 1 : 0)
  end

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be after the start date") if end_date < start_date
  end

  def at_least_one_unit
    errors.add(:units, "must include at least one") if units.blank? || units.reject(&:blank?).empty?
  end
end
