class FinancialEntry < ApplicationRecord
  belongs_to :user

  validates :description, :amount, :date, :entry_type, presence: true
  validates :entry_type, inclusion: { in: %w[income outcome] }
end
