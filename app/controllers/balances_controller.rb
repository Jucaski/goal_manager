class BalancesController < ApplicationController
  before_action :authenticate_user! # Devise helper to ensure the user is logged in

  def index
    # Get entries for the current user
    @entries = current_user.financial_entries.order(date: :desc)
    
    # Setup instances for the forms
    @new_entry = FinancialEntry.new

    # Variables for your views (you can refine these queries by month/year as needed)
    @incomes = @entries.where(entry_type: 'income')
    @outcomes = @entries.where(entry_type: 'outcome')
    
    # Basic math for the balance views
    @total_income = @incomes.sum(:amount)
    @total_outcome = @outcomes.sum(:amount)
    @current_balance = @total_income - @total_outcome
    current_year = Time.current.year
    @year_entries = current_user.financial_entries.where(date: Time.new(current_year).all_year)

    # 1. Create a hash to hold the 12 months, starting with $0 for everything
    @monthly_data = {}
    (1..12).each do |m| 
      @monthly_data[m] = { name: Date::MONTHNAMES[m], income: 0, outcome: 0 } 
    end

    # 2. Loop through the year's entries and add the amounts to the correct month
    @year_entries.each do |entry|
      month = entry.date.month # Gets a number 1-12
      if entry.entry_type == 'income'
        @monthly_data[month][:income] += entry.amount
      else
        @monthly_data[month][:outcome] += entry.amount
      end
    end

    # 3. Calculate the grand totals for the bottom rows
    @yearly_total_income = @year_entries.where(entry_type: 'income').sum(:amount)
    @yearly_total_outcome = @year_entries.where(entry_type: 'outcome').sum(:amount)
    @yearly_balance = @yearly_total_income - @yearly_total_outcome
  end

  def create_entry
    @entry = current_user.financial_entries.build(entry_params)
    
    if @entry.save
      redirect_to balance_path, notice: "#{@entry.entry_type.capitalize} added successfully."
    else
      redirect_to balance_path, alert: "Error adding entry. Please check your inputs."
    end
  end

  private

  def entry_params
    params.require(:financial_entry).permit(:entry_type, :description, :amount, :date, :source_or_category)
  end
end
