class ChineseWord < ApplicationRecord
  has_many :flashcards, dependent: :destroy

  validates :word, presence: true, uniqueness: true
end
