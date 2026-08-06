class BodyMeasurement < ApplicationRecord
  belongs_to :user

  # All measurements in cm. Order matters: keeps the form and graphs consistent.
  MEASUREMENTS = {
    neck: "J Neck",
    bust: "H Bust",
    under_bust: "Under bust",
    waist: "G Waist",
    high_hip: "I High hip",
    full_hip: "Full hip (wider point)",
    shoulder: "Shoulder",
    shoulder_to_waist: "Y-C Shoulder to waist",
    back_width: "P-Q Back width",
    arm_length: "Arm length",
    sleeve_length: "M Sleeve length",
    wrist: "V Wrist",
    bicep: "W Bicep",
    forearm: "Forearm(below the bicep)",
    thigh: "Thigh",
    knee: "Knee",
    calf: "Calf",
    inseam: "T-U Inseam",
    outseam: "R-S Outseam",
    torso_length: "A-B Torso length",
    head: "Head"
  }.freeze

  # Letter reference on the body diagram image, matching MEASUREMENTS order.
  MEASUREMENT_LETTERS = MEASUREMENTS.keys.map.with_index { |key, i| [ key, ("A".."Z").to_a[i] ] }.to_h.freeze

  def self.letter_for(key)
    MEASUREMENT_LETTERS[key.to_sym]
  end

  validates :date, presence: true, uniqueness: { scope: :user_id, message: "already have measurements for this date" }
  validate :at_least_one_measurement

  scope :ordered, -> { order(date: :desc) }
  scope :for_range, ->(from, to) { where(date: from..to) }

  after_initialize :set_default_date, if: :new_record?

  def filled_measurements
    MEASUREMENTS.keys.select { |m| self[m].present? }
  end

  private

  def set_default_date
    self.date ||= Date.current
  end

  def at_least_one_measurement
    return if MEASUREMENTS.keys.any? { |m| self[m].present? }

    errors.add(:base, "enter at least one measurement")
  end
end
