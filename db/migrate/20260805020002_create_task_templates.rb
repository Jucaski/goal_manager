class CreateTaskTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :task_templates do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :tag
      t.references :ringtone, foreign_key: true
      t.integer :alarm_minutes_before, null: false, default: 5

      t.timestamps
    end
  end
end
