class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author
      t.integer :total_pages
      t.string :genre
      t.string :isbn

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
