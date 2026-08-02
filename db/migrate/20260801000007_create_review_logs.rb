class CreateReviewLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :review_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :flashcard, null: false, foreign_key: true
      t.integer :rating, null: false
      t.integer :state_before, null: false
      t.integer :state_after, null: false
      t.date :review_date, null: false

      t.timestamps
    end

    add_index :review_logs, [ :flashcard_id, :review_date ]
  end
end
