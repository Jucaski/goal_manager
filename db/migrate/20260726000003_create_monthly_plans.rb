class CreateMonthlyPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_plans do |t|
      t.integer :year, null: false
      t.integer :month, null: false

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :monthly_plans, [:user_id, :year, :month], unique: true
  end
end
