class CreateFlashcards < ActiveRecord::Migration[8.1]
  def change
    create_table :flashcards do |t|
      t.references :user, null: false, foreign_key: true
      t.references :flashcard_deck, null: false, foreign_key: true
      t.references :chinese_word, null: false, foreign_key: true
      t.integer :state, null: false, default: 0
      t.date :due_date, null: false, default: -> { "CURRENT_DATE" }
      t.float :stability, null: false, default: 0
      t.float :difficulty, null: false, default: 0
      t.integer :elapsed_days, null: false, default: 0
      t.integer :scheduled_days, null: false, default: 0
      t.integer :reps, null: false, default: 0
      t.integer :lapses, null: false, default: 0
      t.date :last_review_date

      t.timestamps
    end

    add_index :flashcards, [ :flashcard_deck_id, :chinese_word_id ], unique: true
    add_index :flashcards, [ :user_id, :due_date ]
  end
end
