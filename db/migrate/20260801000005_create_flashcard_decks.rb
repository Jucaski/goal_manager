class CreateFlashcardDecks < ActiveRecord::Migration[8.1]
  def change
    create_table :flashcard_decks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :kind, null: false, default: "configurable"
      t.jsonb :front_fields, null: false, default: []
      t.jsonb :back_fields, null: false, default: []
      t.jsonb :levels, null: false, default: []
      t.boolean :tts_front, null: false, default: false
      t.boolean :tts_back, null: false, default: false

      t.timestamps
    end
  end
end
