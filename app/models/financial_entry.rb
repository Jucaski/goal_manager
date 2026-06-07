class FinancialEntry < ApplicationRecord
  belongs_to :user

  validates :description, :amount, :date, :entry_type, presence: true
  validates :entry_type, inclusion: { in: %w[income outcome] }

  def calculate_isr_percentage
    return 0 if amount.nil? || amount <= 0
    
    case amount
    when 0..25000            then 0.010
    when 25000.01..50000     then 0.011
    when 50000.01..83333.33  then 0.015
    when 83333.34..208333.33 then 0.020
    else 0.025
    end
  end

  def isr_amount
    amount * calculate_isr_percentage
  end
end
