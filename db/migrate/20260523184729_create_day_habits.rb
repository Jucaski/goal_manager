class CreateDayHabits < ActiveRecord::Migration[8.1]
  def change
    create_table :day_habits do |t|
      t.references :habit, null: false, foreign_key: true
      t.date :date
      t.integer :rating
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
