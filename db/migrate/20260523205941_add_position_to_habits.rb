class AddPositionToHabits < ActiveRecord::Migration[8.1]
  def change
    add_column :habits, :position, :integer, default: 0, null: false
    add_index :habits, [:user_id, :position]
  end
end
