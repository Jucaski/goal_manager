class AddCoverUrlToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :cover_url, :string
  end
end
