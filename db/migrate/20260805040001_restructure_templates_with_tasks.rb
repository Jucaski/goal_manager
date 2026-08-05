class RestructureTemplatesWithTasks < ActiveRecord::Migration[8.1]
  class LegacyTemplate < ActiveRecord::Base
    self.table_name = "task_templates"
  end

  class LegacySchedule < ActiveRecord::Base
    self.table_name = "task_schedules"
  end

  class LegacyLog < ActiveRecord::Base
    self.table_name = "time_logs"
  end

  class NewTask < ActiveRecord::Base
    self.table_name = "tasks"
  end

  def up
    add_column :task_templates, :start_date, :date
    add_column :task_templates, :end_date, :date
    add_column :task_templates, :days_of_week, :integer, array: true, null: false, default: []

    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task_template, null: false, foreign_key: true
      t.time :start_time, null: false
      t.integer :duration_minutes, null: false, default: 60

      t.timestamps
    end

    LegacySchedule.order(:task_template_id, :id).each do |schedule|
      template = LegacyTemplate.find(schedule.task_template_id)
      if template.start_date.blank?
        template.update_columns(
          start_date: schedule.start_date,
          end_date: schedule.end_date,
          days_of_week: schedule.days_of_week
        )
      end

      NewTask.create!(
        user_id: schedule.user_id,
        task_template_id: schedule.task_template_id,
        start_time: schedule.start_time,
        duration_minutes: schedule.duration_minutes
      )
    end

    add_reference :time_logs, :task, foreign_key: true
    LegacyLog.all.each do |log|
      task = NewTask.where(task_template_id: log.task_template_id).first
      log.update_column(:task_id, task&.id)
    end
    remove_reference :time_logs, :task_template

    drop_table :task_schedules
  end

  def down
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

    NewTask.order(:task_template_id, :start_time).each do |task|
      template = LegacyTemplate.find(task.task_template_id)
      LegacySchedule.create!(
        user_id: task.user_id,
        task_template_id: task.task_template_id,
        days_of_week: template.days_of_week,
        start_time: task.start_time,
        duration_minutes: task.duration_minutes,
        start_date: template.start_date || task.created_at.to_date,
        end_date: template.end_date
      )
    end

    add_reference :time_logs, :task_template, foreign_key: true
    LegacyLog.all.each do |log|
      task = NewTask.find(log.task_id) if log.task_id
      log.update_column(:task_template_id, task&.task_template_id)
    end
    remove_reference :time_logs, :task

    drop_table :tasks
    remove_column :task_templates, :start_date
    remove_column :task_templates, :end_date
    remove_column :task_templates, :days_of_week
  end
end
