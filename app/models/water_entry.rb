class WaterEntry < ApplicationRecord
  belongs_to :user

  validates :date, :amount_ml, presence: true
  validates :amount_ml, numericality: { only_integer: true, greater_than: 0 }

  scope :ordered, -> { order(:date) }
  scope :for_range, ->(from, to) { where(date: from..to) }
  scope :for_date, ->(date) { where(date: date) }

  def self.total_ml_for(date)
    for_date(date).sum(:amount_ml)
  end
end
