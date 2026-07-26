class YearlyGoal < ApplicationRecord
  belongs_to :user

  validates :year, presence: true, uniqueness: { scope: :user_id }
  validates :target_books, presence: true, numericality: { greater_than: 0 }
end
