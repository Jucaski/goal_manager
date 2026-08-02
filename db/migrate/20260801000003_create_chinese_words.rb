class CreateChineseWords < ActiveRecord::Migration[8.1]
  def change
    create_table :chinese_words do |t|
      t.references :user, null: false, foreign_key: true
      t.string :word, null: false
      t.string :pinyin
      t.string :part_of_speech
      t.string :translation
      t.integer :level
      t.string :decomposition
      t.text :etymology
      t.string :radical
      t.text :grammar_note
      t.string :example_zh1
      t.string :example_en1
      t.string :example_zh2
      t.string :example_en2
      t.string :example_zh3
      t.string :example_en3

      t.timestamps
    end

    add_index :chinese_words, [ :user_id, :word ], unique: true
  end
end
