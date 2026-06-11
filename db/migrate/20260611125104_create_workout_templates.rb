class CreateWorkoutTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_templates do |t|
      t.string :name
      t.integer :sets
      t.integer :work_duration
      t.integer :rest_duration
      t.boolean :is_running
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
