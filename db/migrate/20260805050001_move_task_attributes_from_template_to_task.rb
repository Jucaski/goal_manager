class MoveTaskAttributesFromTemplateToTask < ActiveRecord::Migration[8.1]
  def up
    add_column :tasks, :title, :string
    add_column :tasks, :tag, :string
    add_column :tasks, :ringtone_id, :bigint
    add_column :tasks, :alarm_minutes_before, :integer, null: false, default: 5

    add_foreign_key :tasks, :ringtones

    execute <<~SQL.squish
      UPDATE tasks
      SET title = COALESCE(tasks.title, task_templates.name),
          tag = COALESCE(tasks.tag, task_templates.tag),
          ringtone_id = COALESCE(tasks.ringtone_id, task_templates.ringtone_id),
          alarm_minutes_before = COALESCE(tasks.alarm_minutes_before, task_templates.alarm_minutes_before, 5)
      FROM task_templates
      WHERE tasks.task_template_id = task_templates.id
    SQL

    change_column_null :tasks, :title, false

    remove_column :task_templates, :tag
    remove_column :task_templates, :ringtone_id
    remove_column :task_templates, :alarm_minutes_before
  end

  def down
    add_column :task_templates, :tag, :string
    add_column :task_templates, :ringtone_id, :bigint
    add_column :task_templates, :alarm_minutes_before, :integer, null: false, default: 5

    add_foreign_key :task_templates, :ringtones

    execute <<~SQL.squish
      UPDATE task_templates
      SET tag = tasks.tag,
          ringtone_id = tasks.ringtone_id,
          alarm_minutes_before = tasks.alarm_minutes_before
      FROM tasks
      WHERE tasks.task_template_id = task_templates.id
    SQL

    remove_column :tasks, :title
    remove_column :tasks, :tag
    remove_column :tasks, :ringtone_id
    remove_column :tasks, :alarm_minutes_before
  end
end
