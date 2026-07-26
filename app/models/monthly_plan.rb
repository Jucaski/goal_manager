class MonthlyPlan < ApplicationRecord
  belongs_to :user
  has_many :planned_books, dependent: :destroy
  has_many :books, through: :planned_books

  validates :year, :month, presence: true
  validates :month, inclusion: { in: 1..12 }
  validates :year, uniqueness: { scope: [:user_id, :month] }

  scope :for_year, ->(year) { where(year: year) }
end
