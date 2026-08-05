class CreateTimeLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :time_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task_template, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :ended_at

      t.timestamps
    end

    add_index :time_logs, [ :user_id, :started_at ]
  end
end
