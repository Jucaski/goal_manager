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
