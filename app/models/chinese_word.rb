class ChineseWord < ApplicationRecord
  belongs_to :user
  has_many :flashcards, dependent: :destroy

  validates :word, presence: true
  validates :word, uniqueness: { scope: :user_id }
end
