class CreateCounters < ActiveRecord::Migration[8.1]
  def change
    create_table :counters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :tag
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :direction, null: false, default: "descending"
      t.string :units, array: true, default: [], null: false
      t.integer :duration_value
      t.string :duration_unit

      t.timestamps
    end

    add_index :counters, [ :user_id, :tag ]
  end
end
