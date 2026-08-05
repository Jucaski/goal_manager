class CreateWaterEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :water_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :amount_ml, null: false

      t.timestamps
    end

    add_index :water_entries, [ :user_id, :date ]
  end
end
