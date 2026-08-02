class MakeChineseWordsGlobal < ActiveRecord::Migration[8.1]
  def up
    # 1. Point every flashcard at the canonical (lowest-id) chinese_word for its word.
    execute <<~SQL
      UPDATE flashcards f
      SET chinese_word_id = (
        SELECT MIN(id) FROM chinese_words
        WHERE word = (SELECT word FROM chinese_words WHERE id = f.chinese_word_id)
      )
    SQL

    # 2. Keep one chinese_words row per word (the lowest id), delete duplicates.
    execute <<~SQL
      DELETE FROM chinese_words a
      USING chinese_words b
      WHERE a.word = b.word AND a.id > b.id
    SQL

    # 3. Words are no longer user-owned.
    remove_foreign_key :chinese_words, :users
    remove_index :chinese_words, name: "index_chinese_words_on_user_id_and_word"
    remove_index :chinese_words, name: "index_chinese_words_on_user_id"
    remove_column :chinese_words, :user_id

    # 4. Words are globally unique.
    add_index :chinese_words, :word, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
