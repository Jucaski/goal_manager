class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :note_type, null: false, default: "typed"
      t.text :content
      t.text :ocr_text
      t.jsonb :drawing_data, default: []
      t.string :tags, array: true, default: [], null: false

      t.timestamps
    end

    add_index :notes, [ :user_id, :note_type ]
    add_index :notes, :tags, using: :gin
  end
end
