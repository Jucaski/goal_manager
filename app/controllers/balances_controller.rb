class BalancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: [:edit, :update, :destroy]

  def index
    if params[:month].present? && params[:year].present?
      @target_date = Date.new(params[:year].to_i, params[:month].to_i, 1)
    else
      @target_date = Time.current
    end

    @entries = current_user.financial_entries
                         .where(date: @target_date.all_month)
                         .order(date: :desc)

    @pending_outcomes = current_user.financial_entries.pending_table
  
    @fulfilled_outcomes = current_user.financial_entries.fulfilled_table.where(date: @target_date.all_month)

    @new_entry = FinancialEntry.new

    @incomes = @entries.where(entry_type: 'income')
    @outcomes = @entries.where(entry_type: 'outcome').main_transactions
    @previous_month_date = Time.current.last_month
    
    @previous_month_incomes = current_user.financial_entries
                                          .where(entry_type: 'income', date: @previous_month_date.all_month)
                                          .order(date: :asc)
    
    @total_income = @incomes.sum(:amount)
    @total_outcome = @outcomes.sum(:amount)
    @current_balance = @total_income - @total_outcome
    current_year = Time.current.year
    @year_entries = current_user.financial_entries.where(date: Time.new(current_year).all_year)

    @monthly_data = {}
    (1..12).each do |m| 
      @monthly_data[m] = { name: Date::MONTHNAMES[m], income: 0, outcome: 0 } 
    end

    @year_entries.each do |entry|
      month = entry.date.month # Gets a number 1-12
      if entry.entry_type == 'income'
        @monthly_data[month][:income] += entry.amount
      else
        @monthly_data[month][:outcome] += entry.amount
      end
    end

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

  def edit
    @entry
  end

  def update
    if @entry.update(entry_params)
      redirect_to balance_path, notice: "Transaction updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @entry.destroy
      redirect_to balance_path, notice: "Transaction deleted successfully."
    else
      redirect_to balance_path, alert: "Could not delete transaction."
    end
  end

  def mark_as_paid
    @entry = current_user.financial_entries.find(params[:id])
    @entry.update!(status: 2, date: Date.current)
    redirect_to balance_path, notice: "Payment fulfilled!"
  end

  private

  def set_entry
    @entry = current_user.financial_entries.find(params[:id])
  end

  def entry_params
    params.require(:financial_entry).permit(:entry_type, :description, :amount, :date, :source_or_category, :status)
  end
end
