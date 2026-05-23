class DayHabit < ApplicationRecord
  belongs_to :habit
  belongs_to :user

  validates :date, presence: true
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
end
