class ChangeWorkoutTemplateIdToAllowNullInWorkoutSessions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :workout_sessions, :workout_template_id, true
  end
end
