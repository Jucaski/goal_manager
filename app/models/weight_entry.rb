class WeightEntry < ApplicationRecord
  belongs_to :user

  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true, uniqueness: { scope: :user_id, message: "already have an entry for this date" }

  scope :ordered, -> { order(date: :desc) }
  scope :for_range, ->(from, to) { where(date: from..to) }

  after_initialize :set_default_date, if: :new_record?

  private

  def set_default_date
    self.date ||= Date.current
  end
end
