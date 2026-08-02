class ReviewLog < ApplicationRecord
  belongs_to :user
  belongs_to :flashcard

  validates :rating, inclusion: { in: 1..4 }
end
