class CreateTaskSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :task_schedules do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task_template, null: false, foreign_key: true
      t.integer :days_of_week, array: true, null: false, default: []
      t.time :start_time, null: false
      t.integer :duration_minutes, null: false, default: 60
      t.date :start_date, null: false
      t.date :end_date

      t.timestamps
    end

    add_index :task_schedules, [ :user_id, :start_date, :end_date ]
  end
end
