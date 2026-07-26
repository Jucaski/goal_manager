class CreateReadingLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_logs do |t|
      t.references :book, null: false, foreign_key: true
      t.date :start_date
      t.date :finish_date
      t.integer :rating
      t.text :notes

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :reading_logs, [:user_id, :book_id], unique: true
  end
end
