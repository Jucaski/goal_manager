class AddStatusToFinancialEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :financial_entries, :status, :integer
  end
end
