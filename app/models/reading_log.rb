class ReadingLog < ApplicationRecord
  belongs_to :book
  belongs_to :user

  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :book_id, uniqueness: { scope: :user_id }

  validate :finish_after_start

  private

  def finish_after_start
    return if start_date.blank? || finish_date.blank?
    if finish_date < start_date
      errors.add(:finish_date, "must be after the start date")
    end
  end
end
