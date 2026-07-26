class CreateYearlyGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :yearly_goals do |t|
      t.integer :year, null: false
      t.integer :target_books, null: false

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :yearly_goals, [:user_id, :year], unique: true
  end
end
