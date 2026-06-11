class CreateWorkoutSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_sessions do |t|
      t.date :date
      t.integer :sets
      t.integer :work_duration
      t.integer :rest_duration
      t.boolean :is_running
      t.text :note
      t.float :distance
      t.integer :calories
      t.float :max_pace
      t.references :workout_template, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
