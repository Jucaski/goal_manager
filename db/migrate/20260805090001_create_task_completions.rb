class CreateTaskCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :task_completions do |t|
      t.bigint "task_id", null: false
      t.bigint "user_id", null: false
      t.date "date", null: false
      t.timestamps

      t.index ["task_id", "date"], unique: true
      t.index ["task_id"], name: "index_task_completions_on_task_id"
      t.index ["user_id"], name: "index_task_completions_on_user_id"
    end

    add_foreign_key "task_completions", "users"
    add_foreign_key "task_completions", "tasks"
  end
end
