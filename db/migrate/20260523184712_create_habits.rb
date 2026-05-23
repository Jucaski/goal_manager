class CreateHabits < ActiveRecord::Migration[8.1]
  def change
    create_table :habits do |t|
      t.string :title
      t.references :user, null: false, foreign_key: true
      t.date :completed_date

      t.timestamps
    end
  end
end
