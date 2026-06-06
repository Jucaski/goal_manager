class CreateFinancialEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :financial_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :entry_type
      t.string :description
      t.decimal :amount
      t.date :date
      t.string :source_or_category

      t.timestamps
    end
  end
end
