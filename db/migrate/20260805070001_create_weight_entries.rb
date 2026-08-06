class CreateWeightEntries < ActiveRecord::Migration[8.1]
  def up
    return if table_exists?(:weight_entries)

    create_table :weight_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :weight
      t.date :date

      t.timestamps
    end
  end

  def down
    drop_table :weight_entries if table_exists?(:weight_entries)
  end
end
