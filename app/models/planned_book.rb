class PlannedBook < ApplicationRecord
  belongs_to :monthly_plan
  belongs_to :book
  belongs_to :user

  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :book_id, uniqueness: { scope: :monthly_plan_id }

  scope :ordered, -> { order(:position) }
end
