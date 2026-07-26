class CreatePlannedBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :planned_books do |t|
      t.references :monthly_plan, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :position

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :planned_books, [:monthly_plan_id, :book_id], unique: true
  end
end
