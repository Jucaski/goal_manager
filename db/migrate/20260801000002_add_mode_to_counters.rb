class AddModeToCounters < ActiveRecord::Migration[8.1]
  def change
    add_column :counters, :mode, :string, default: "duration", null: false
  end
end
