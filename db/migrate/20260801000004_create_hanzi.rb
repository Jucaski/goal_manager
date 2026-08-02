class CreateHanzi < ActiveRecord::Migration[8.1]
  def change
    create_table :hanzi, id: false do |t|
      t.string :character, null: false, primary_key: true
      t.jsonb :strokes, null: false, default: []
      t.jsonb :medians, null: false, default: []

      t.timestamps
    end
  end
end
