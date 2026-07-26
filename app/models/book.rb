class Book < ApplicationRecord
  belongs_to :user
  has_one :reading_log, dependent: :destroy
  has_many :planned_books, dependent: :destroy
  has_many :monthly_plans, through: :planned_books

  validates :title, presence: true
  validates :total_pages, numericality: { greater_than: 0 }, allow_nil: true
end
